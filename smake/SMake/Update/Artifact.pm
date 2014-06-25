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
use SMake::Model::Const;
use SMake::Update::Resource;
use SMake::Update::Stage;

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
    $this->{descriptions} = {map {$_ => 0} @{$artifact->getDescriptionKeys()}};
    $this->{stages} = {map {$_ => 0} @{$artifact->getStageNames()}};
    $this->{resources} = {map {$_ => 0} @{$artifact->getResourceNames()}};
  }
  else {
    $artifact = $project->getObject()->createArtifact($path, $name, $type, $args);
    $this->{descriptions} = {};
    $this->{stages} = {};
    $this->{resources} = {};
  }
  $this->{project} = $project;
  $this->{artifact} = $artifact;
  
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  foreach my $stage (keys %{$this->{stages}}) {
    $stage->destroy() if($stage);
  }
  $this->{stages} = undef;
  foreach my $resource (keys %{$this->{resources}}) {
    $resource->destroy() if($resource);
  }
  $this->{stages} = undef;
  $this->{project} = undef;
  $this->{artifact} = undef;
}

# Get artifact model object
sub getObject {
  my ($this) = @_;
  return $this->{artifact};
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

# Create resource
#
# Usage: createResource($context, $path, $type, $task)
#    context ... parser context
#    name ...... name of the resource (relative path based on the artifact)
#    type ...... type of the resource
#    task ...... a task which generates this resource
sub createResource {
  my ($this, $context, $name, $type, $task) = @_;
  
  my $resource = SMake::Update::Resource->new(
      $context, $this, $name, $type, $task);
  $this->{resources}->{$name->hashKey()} = $resource;
  $task->appendTarget($context, $resource);
  return $resource;
}

# Get list of resources
#
# Usage: getResources($context)
# Returns: \@list
sub getResources {
  my ($this, $context) = @_;
  return [values(%{$this->{resources}})];
}

# Append main resource
#
# Usage: appendMainResource($context, $type, $resource)
#    context ..... parser context
#    type ........ type of the main resource
#    resource .... the resource object
sub appendMainResource {
  my ($this, $context, $type, $resource) = @_;
  $this->{artifact}->appendMainResource($type, $resource->getObject());
}

# Create new stage object or use already existing
#
# Usage: createStage($context, $name)
# Returns: the stage object
sub createStage {
  my ($this, $context, $name) = @_;

  my $stage = $this->{stages}->{$name};
  if(!$stage) {
    $stage = SMake::Update::Stage->new($context, $this, $name);
    $this->{stages}->{$name} = $stage;
  }
  return $stage;
}

# A helper method - create a task in a stage
#
# Usage: createTaskInStage($context, $stage, $task, $wd, \%args)
#    context ..... parser context
#    stage ....... name of the stage
#    task ........ name of the task
#    type ........ type of the task
#    wd .......... task's working directory (a path object with repository meaning)
#    args ........ optional task arguments
sub createTaskInStage {
  my ($this, $context, $stage, $task, $type, $wd, $args) = @_;
  
  # -- stage object
  my $stageobj = $this->createStage($context, $stage);
  # -- task object
  return $stageobj->createTask($context, $task, $type, $wd, $args);
}

# A helper method - append source resources
#
# Usage: appendSourceResources($context, $prefix, \@srclist)
#    context ..... parser context
#    prefix ...... relative path of the sources based on this artifact
#    srclist ..... list of sources (names of resources)
# Returns: undef if everything is OK, name of wrong resource otherwise
sub appendSourceResources {
  my ($this, $context, $prefix, $srclist) = @_;
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
        $respath->asString(),
        $SMake::Model::Const::SOURCE_STAGE,
        $SMake::Model::Const::SOURCE_TASK,
        $this->getPath(),
        undef);
    
    # -- create resource
    my $resource = $this->createResource(
        $context,
        $prefix->joinPaths($name),
        $SMake::Model::Const::SOURCE_RESOURCE,
        $task);
  }
  
  return undef;
}

return 1;
