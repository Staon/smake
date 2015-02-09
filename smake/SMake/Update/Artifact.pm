# Copyright (C) 2014 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is a free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SMake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SMake.  If not, see <http://www.gnu.org/licenses/>.

# Updateable artifact object
package SMake::Update::Artifact;

use SMake::Data::Path;
use SMake::Model::ActiveFeature;
use SMake::Model::Const;
use SMake::Model::Dependency;
use SMake::Model::Feature;
use SMake::Model::Resource;
use SMake::Model::Stage;
use SMake::Update::ActiveFeature;
use SMake::Update::Dependency;
use SMake::Update::Feature;
use SMake::Update::Resource;
use SMake::Update::Stage;
use SMake::Update::Table;
use SMake::Utils::Construct;

# Create new object
#
# Usage: new($context, $project, $path, $name, $type, \%args)
#    context ...... parser context
#    project ...... parent project object
#    path ......... logical path of the artifact
#    name ......... name of the artifact
#    type ......... type of the artifact
#    args ......... optional arguments of the artifact
sub new {
  my ($class, $context, $project, $path, $name, $type, $args) = @_;
  my $this = bless({}, $class);
  
  my $artifact = $project->getObject()->getArtifact($name);
  if(defined($artifact)) {
    $artifact->update($path, $type, $args);
    
    $this->{resources} = SMake::Update::Table->new(
        \&SMake::Model::Resource::createKey,
        $artifact->getResourceKeys());
    $this->{stages} = SMake::Update::Table->new(
        \&SMake::Model::Stage::createKey,
        $artifact->getStageKeys());
    $this->{dependencies} = SMake::Update::Table->new(
        \&SMake::Model::Dependency::createKey,
        $artifact->getDependencyKeys());
    $this->{features} = SMake::Update::Table->new(
        \&SMake::Model::Feature::createKey,
        $artifact->getFeatureKeys());
    $this->{active_features} = SMake::Update::Table->new(
        \&SMake::Model::ActiveFeature::createKey,
        $artifact->getActiveFeatureKeys());
  }
  else {
    $artifact = $project->getObject()->createArtifact($path, $name, $type, $args);

    $this->{resources} = SMake::Update::Table->new(
        \&SMake::Model::Resource::createKey, []);
    $this->{stages} = SMake::Update::Table->new(
        \&SMake::Model::Stage::createKey, []);
    $this->{dependencies} = SMake::Update::Table->new(
        \&SMake::Model::Dependency::createKey, []);
    $this->{features} = SMake::Update::Table->new(
        \&SMake::Model::Feature::createKey, []);
    $this->{active_features} = SMake::Update::Table->new(
        \&SMake::Model::ActiveFeature::createKey, []);
  }
  $this->{main_resources} = {};
  $this->{main} = undef;
  $this->{project} = $project;
  $this->{artifact} = $artifact;
  
  return $this;
}

sub update {
  my ($this, $context) = @_;

  # -- update stages (must be before update of the resources)
  my ($stage_delete, undef) = $this->{stages}->update($context);
  $this->{artifact}->deleteStages($stage_delete);

  # -- update main resources (must be before update of the resources)
  my $main = $this->{main};
  $this->{artifact}->setMainResources(
      (defined($main))?$main->getObject():undef,
      {map {$_ => $this->{main_resources}->{$_}->getObject()}
          keys(%{$this->{main_resources}})});
  
  # -- update resources
  my ($res_delete, undef) = $this->{resources}->update($context);
  $this->{artifact}->deleteResources($res_delete);
  
  # -- update dependencies
  my ($dep_delete, undef) = $this->{dependencies}->update($context);
  $this->{artifact}->deleteDependencies($dep_delete);
  
  # -- update features
  my ($feature_delete, undef) = $this->{features}->update($context);
  $this->{artifact}->deleteFeatures($feature_delete);

  # -- update features
  my ($actfeature_delete, undef) = $this->{active_features}->update($context);
  $this->{artifact}->deleteActiveFeatures($actfeature_delete);
  
  $this->{stages} = undef;
  $this->{resources} = undef;
  $this->{main_resources} = undef;
  $this->{dependencies} = undef;
  $this->{features} = undef;
  $this->{active_features} = undef;
  $this->{project} = undef;
  $this->{artifact} = undef;
}

# Get artifact model object
sub getObject {
  my ($this) = @_;
  return $this->{artifact};
}

# Get key tuple
sub getKeyTuple {
  my ($this) = @_;
  return $this->{artifact}->getKeyTuple();
}

# Get string key
sub getKey {
  my ($this) = @_;
  return $this->{artifact}->getKey();
}

# Get name of the artifact
sub getName {
  my ($this) = @_;
  return $this->{artifact}->getName();
}

# Get type of the artifact
sub getType {
  my ($this) = @_;
  return $this->{artifact}->getType();
}

# Get arguments of the artifact
sub getArguments {
  my ($this) = @_;
  return $this->{artifact}->getArguments();
}

# Get artifact path
sub getPath {
  my ($this) = @_;
  return $this->{artifact}->getPath();
}

# Get project which the artifact belongs to
sub getProject {
  my ($this) = @_;
  return $this->{project};
}

# Create resource or use already created
#
# Usage: createResource($context, $location, $type, $name, $task)
#    context ... parser context
#    location .. location type
#    type ...... type of the resource
#    name ...... name of the resource (relative path based on the artifact)
#    task ...... a task which generates this resource
sub createResource {
  my ($this, $context, $location, $type, $name, $task) = @_;

  my $resource = SMake::Update::Resource->new(
      $context, $this, $location, $type, $name, $task);
  $this->{resources}->addItem($resource);
  $task->appendTarget($context, $resource);
  return $resource;
}

# Create a product directory resource
#
# Usage: createProductResource($context, $path)
#    context ... parser context
#    name ...... name of the resource (relative path based on the artifact)
#    parentres . parent directory resource. It can be null.
# Returns: the resource
sub createProductDirResource {
  my ($this, $context, $name, $parentres) = @_;

  # -- check if the resource already exists
  my $resource = $this->getResource(
      $SMake::Model::Const::PRODUCT_LOCATION,
      $SMake::Model::Const::BUILD_TREE_RESOURCE,
      $name);
  if(!defined($resource)) {
    # -- it doesn't -> create new
    my $dirtask = $this->createTaskInStage(
        $context,
        $SMake::Model::Const::BUILD_TREE_STAGE,
        $SMake::Model::Const::BUILD_TREE_TASK . ":" . $name->asString(),
        $SMake::Model::Const::BUILD_TREE_TASK,
        undef,
        undef,
        undef);
    $resource = $this->createResource(
        $context,
        $SMake::Model::Const::PRODUCT_LOCATION,
        $SMake::Model::Const::BUILD_TREE_RESOURCE,
        $name,
        $dirtask);
    if(defined($parentres)) {
      $dirtask->appendSource($context, $parentres);
    }
  }
  
  return $resource;
}

# Create a product resource - if the build directory differs the source directory,
# target directories are created too.
#
# Usage: createProductResource($context, $path, $type, $task)
#    context ... parser context
#    name ...... name of the resource (relative path based on the artifact)
#    type ...... type of the resource
#    task ...... a task which generates this resource
sub createProductResource {
  my ($this, $context, $type, $name, $task) = @_;

  # -- create the resource
  my $resource = $this->createResource(
      $context, $SMake::Model::Const::PRODUCT_LOCATION, $type, $name, $task);

  # -- create the directory resources
  my $parentres;
  if($context->getRepository()->isBuildTreeSeparated()) {
    my $path = $name->getDirpath();
    while(1) {
      my $dirres = $this->createProductDirResource($context, $path, $parentres);
      $parentres = $dirres;
      last if($path->isEmpty());
      $path = $path->getDirpath();
    }
  }
  if(defined($parentres)) {
    $task->appendSource($context, $parentres);
  }
  
  return $resource;
}

# Get resource object
#
# Usage: getResource($location, $type, $name)
#    location .. resource location type
#    type ...... type of the resource
#    name ...... name of the resource (relative path)
# Returns: the resource or undef
sub getResource {
  my ($this, $location, $type, $name) = @_;

  my $resource = $this->{resources}->getItemByKey(
      SMake::Model::Resource::createKey($location, $type, $name));
  return ($resource)?$resource:undef;
}

# Get list of resources
#
# Usage: getResources($context)
# Returns: \@list
sub getResources {
  my ($this, $context) = @_;
  return $this->{resources}->getItems();
}

# Search for a resource in the artifact
#
# Usage: searchResource($restype, $path, $location)
#    restype ..... regular expression of searched resource types
#    path ........ relative path (name) of the searched resource
#    location .... regular expression of resource location type
# Returns: searched resource or undef
sub searchResource {
  my ($this, $restype, $path, $location) = @_;

  my $list = $this->{resources}->getItems();
  if(defined($list)) {
    foreach my $resource (@$list) {
      if($resource->getType() =~ /$restype/
         && $resource->getLocation() =~ /$location/
         && $path->isEqual($resource->getName())) {
        return $resource;
      }
    }
  }
  return undef;
}

# Append main resource
#
# Usage: appendMainResource($context, $type, $resource)
#    context ..... parser context
#    type ........ type of the main resource
#    resource .... the resource object
sub appendMainResource {
  my ($this, $context, $type, $resource) = @_;
  
  # -- check existence of the resource
  my $r = $this->{resources}->getItemByKey($resource->getKey());
  if(!defined($r) || ($r != $resource)) {
    die "the main resource must be part of the artifact";
  }
  
  $this->{main_resources}->{$type} = $resource;
  if(!defined($this->{main})) {
    $this->{main} = $resource;
  }
}

# Get main resource of the artifact
#
# Usage: getMainResource($type)
# Returns: the resource or undef
sub getMainResource {
  my ($this, $type) = @_;
  return $this->{main_resources}->{$type};
}

# Get default main resource
#
# Usage: getDefaultMainResource()
# Returns: the resource or undef
sub getDefaultMainResource {
  my ($this, $type) = @_;
  return $this->{main};
}

# Create new stage object or use already existing
#
# Usage: createStage($context, $name)
# Returns: the stage object
sub createStage {
  my ($this, $context, $name) = @_;

  my $stage = $this->{stages}->getItemByKey(SMake::Model::Stage::createKey($name));
  if(!$stage) {
    $stage = SMake::Update::Stage->new($context, $this, $name);
    $this->{stages}->addItem($stage);
  }
  return $stage;
}

# Get stage object
#
# Usage: getStage($name)
#    name ..... name of the stage
# Returns: the stage or undef
sub getStage {
  my ($this, $name) = @_;
  return $this->{stages}->getItemByKey(SMake::Model::Stage::createKey($name));
}

# Get list of stages
sub getStages {
  my ($this) = @_;
  return $this->{stages}->getItems();
}

# Create resource dependency
#
# Usage: createResourceDependency($context, $deptype, $depprj, $departifact, $maintype)
#    context ....... parser context
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    maintype ...... type of the main resource
# Returns: the dependency object
sub createResourceDependency {
  my ($this, $context, $deptype, $depprj, $departifact, $maintype) = @_;
  return $this->createDependency(
      $context,
      $SMake::Model::Dependency::RESOURCE_KIND,
      $deptype,
      $depprj,
      $departifact,
      $maintype);
}

# Create stage dependency
#
# Usage: createStageDependency($context, $deptype, $depprj, $departifact, $depstage)
#    context ....... parser context
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    depstage ...... name of the dependency stage
# Returns: the dependency object
sub createStageDependency {
  my ($this, $context, $deptype, $depprj, $departifact, $depstage) = @_;
  return $this->createDependency(
      $context,
      $SMake::Model::Dependency::STAGE_KIND,
      $deptype,
      $depprj,
      $departifact,
      $depstage);
}

# Create new dependency
#
# Usage: createDependency($context, $depkind, $deptype, $depprj, $departifact, $maintype)
#    context ....... parser context
#    depkind ....... dependency kind
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    maintype ...... type of the main artifact (can be undef for default)
# Returns: the dependency object
sub createDependency {
  my $this = shift;
  my $context = shift;
  
  my $dep = SMake::Update::Dependency->new($context, $this, @_);
  $this->{dependencies}->addItem($dep);
  return $dep;
}

# Get dependency object
#
# Usage: getDependency($depkind, $deptype, $depprj, $departifact, ...)
#    depkind ....... kind of the dependency
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
sub getDependency {
  my $this = shift;
  return $this->{dependencies}->getItemByKey(SMake::Model::Dependency::createKey(@_));
}

# Get list of dependency objects
#
# Usage: getDependencyRecords()
# Returns: \@list
sub getDependencyRecords {
  my ($this) = @_;
  return $this->{dependencies}->getItems();
}

# A helper method - create a task in a stage
#
# Usage: createTaskInStage($context, $stage, $task, $wdtype, $wd, $args)
#    stage ....... name of the stage
#    task ........ name of the task
#    type ........ type of the task
#    wdtype ...... resource location type of the working directory
#    wd .......... task's working directory (a path object with repository meaning)
#    args ........ optional task arguments
sub createTaskInStage {
  my ($this, $context, $stage, $task, $type, $wdtype, $wd, $args) = @_;
  
  # -- stage object
  my $stageobj = $this->createStage($context, $stage);
  # -- task object
  return $stageobj->createTask($context, $task, $type, $wdtype, $wd, $args);
}

# A helper method - append source resources
#
# Usage: appendSourceResources($context, $prefix, \@srclist, \@reslist)
#    context ..... parser context
#    prefix ...... relative path of the sources based on this artifact
#    srclist ..... list of sources (names of resources)
#    reslist ..... (out) all newly created resources must be added here
# Returns: undef if everything is OK, name of wrong resource otherwise
sub appendSourceResources {
  my ($this, $context, $prefix, $srclist, $reslist) = @_;
  return undef if($#$srclist < 0);  # -- optimization

  # -- get the source stage (create new or use an already existing)
  my $stage = $this->createStage(
      $context, $SMake::Model::Const::SOURCE_STAGE);
  
  # -- process the source list
  foreach my $src (@$srclist) {
    my $name = SMake::Data::Path->new($src);
    if(!$name->isBasepath()) {
      return $src;
    }

    # -- create task
    my $respath = $prefix->joinPaths($name);
    my $task = $this->createTaskInStage(
        $context,
        $SMake::Model::Const::SOURCE_STAGE,
        $respath->asString(),
        $SMake::Model::Const::SOURCE_TASK,
        undef,
        undef,
        undef);
    
    # -- create resource
    my $resource = $this->createResource(
        $context,
        $SMake::Model::Const::SOURCE_LOCATION,
        $SMake::Model::Const::SOURCE_RESOURCE,
        $prefix->joinPaths($name),
        $task);
    push @$reslist, $resource;
  }
  
  return undef;
}

# -- Append dependencies according to specification from an SMakefile
#
# Usage: appendDependencySpecs($context, $subsystem, $deptype, \@deplist)
#    context ...... parser/executor context
#    subsystem .... logging subsystem
#    deptype ...... type of added dependencies
#    deplist ...... list of dependency specifications (like the directive Deps)
# Returns: \@list list of added dependencies
sub appendDependencySpecs {
  my ($this, $context, $subsystem, $deptype, $deplist) = @_;

  # -- parse dependency specifications
  my $specs = SMake::Utils::Construct::parseDependencySpecs(
      $context->getProject()->getName(), $deplist);
  
  # -- append dependencies
  my $added = [];
  foreach my $spec (@$specs) {
    my ($project, $artifact, $mainres) = @$spec;
    
    # -- main dependency
    my $depobject = $this->createResourceDependency(
        $context, $deptype, $project, $artifact, $mainres);
    push @$added, $depobject;
  }
  
  return $added;
}

# Create new feature object
#
# Usage: createFeature($context, $name)
#    context ........ parser context
#    name ........... name of the feature
# Returns: the feature object
sub createFeature {
  my ($this, $context, $name) = @_;
  
  my $feature = SMake::Update::Feature->new($context, $this, $name);
  $this->{features}->addItem($feature);
  return $feature;
}

# Get a feature object
#
# Usage: getFeature($context, $name)
#    context ........ parser context
#    name ........... name of the feature
# Returns: the feature object or undef
sub getFeature {
  my ($this, $context, $name) = @_;
  return $this->{features}->getItemByKey(SMake::Model::Feature::createKey($name));  
}

# Get list of features
#
# Usage: getFeatures($context)
#    context ........ parser context
# Returns: \@list
sub getFeatures {
  my ($this, $context) = @_;
  return $this->{features}->getItems();
}

# Create new active feature
#
# Usage: createActiveFeature($context, $name)
#    context ........ parser context
#    name ........... name of the feature
# Returns: the feature object
sub createActiveFeature {
  my ($this, $context, $name) = @_;
  
  my $feature = SMake::Update::ActiveFeature->new($context, $this, $name);
  $this->{active_features}->addItem($feature);
  return $feature;
}

# Get list of active features
#
# Usage: getActiveFeatures($context)
#    context ........ parser context
# Returns: \@list of active feature objects
sub getActiveFeatures {
  my ($this, $context) = @_;
  return $this->{active_features}->getItems();
}

return 1;
