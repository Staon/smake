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

# Generic artifact interface. An artifact is a product of the smake project
# like a library, binary or a package.
package SMake::Model::Artifact;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Data::Path;
use SMake::Model::Const;
use SMake::Utils::Abstract;
use SMake::Utils::Utils;

# Create new artifact
#
# Usage: new();
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the artifact
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the artifact
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get arguments of the artifact
sub getArguments {
  SMake::Utils::Abstract::dieAbstract();
}

# Get location of the artifact (its directory). The value has meaning in the context
# of the repository.
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get project which the artifact belongs to
sub getProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Attach a description file with the artifact
#
# Usage: attachDescription($description)
sub attachDescription {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new resource
#
# Usage: createResource($prefix, $name, $type, $task)
#    name ...... name of the resource (relative path based on the artifact)
#    type ...... type of the resource
#    task ...... a task which generates this resource
sub createResource {
  my ($this, $name, $type, $task) = @_;
  
  my $resource = $this->createResourceRaw($name, $type, $task);
  $task->appendTarget($resource);
  return $resource;
}

# Create new resource
#
# Usage: createResource($prefix, $name, $type)
#    name ...... name of the resource
#    type ...... type of the resource
#    task ...... a task which generates this resource
sub createResourceRaw {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new stage or use already created
#
# Usage: createStage($name)
#    name ...... name of the stage
sub createStage {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stage
#
# Usage: getStage($name)
# Returns: the stage or undef
sub getStage {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of resources of the artifact
#
# Usage: getResources()
# Returns: \@list
sub getResources {
  SMake::Utils::Abstract::dieAbstract();
}

# Add a main resource
#
# Usage: addMainResource($type, $resource)
#    type ...... type of the main resource
#    resource .. the resource. The resource must be a resource of the
#                artifact!
sub appendMainResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get main resource of the artifact
#
# Usage: getMainResource($type)
# Returns: the resource or undef
sub getMainResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get default main resource
#
# Usage: getDefaultMainResource()
# Returns: the resource or undef
sub getDefaultMainResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new dependency
#
# Usage: createDependency($deptype, $depprj, $departifact)
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
sub createDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of dependency objects
#
# Usage: getDependencyRecords()
# Returns: \@list
sub getDependencyRecords {
  SMake::Utils::Abstract::dieAbstract();
}

# A helper method - create a task in a stage
#
# Usage: createTaskInStage($stage, $task, $wd, \%args)
#    stage ..... name of the stage
#    task ...... type of the task
#    wd ........ task's working directory (a path object with repository meaning)
#    args ...... optional task arguments
sub createTaskInStage {
  my ($this, $stage, $task, $wd, $args) = @_;
  
  # -- stage object
  my $stageobj = $this->createStage($stage);
  # -- task object
  return $stageobj->createTask($task, $wd, $args);
}

# A helper method - append source resources
#
# Usage: appendSourceResources($prefix, \@srclist)
#    prefix .... relative path of the sources based on this artifact
#    srclist ... list of sources (names of resources)
#    reporter .. a reporter
#    subsys .... reporter subsystem
# Returns: undef if everything is OK, name of wrong resource otherwise
sub appendSourceResources {
  my ($this, $prefix, $srclist) = @_;
  return undef if($#$srclist < 0);  # -- optimization

  # -- get the source stage (create new or use an already existing)
  my $stage = $this->createStage($SMake::Model::Const::SOURCE_STAGE);
  
  # -- process the source list
  foreach my $src (@$srclist) {
    my $name = SMake::Data::Path->new($src);
    if(!$name->isBasepath()) {
      return $src;
    }

    # -- create task
    my $task = $this->createTaskInStage(
        $SMake::Model::Const::SOURCE_STAGE,
        $SMake::Model::Const::SOURCE_TASK,
        $this->getPath(),
        undef);
    
    # -- create resource
    my $resource = $this->createResource(
        $prefix->joinPaths($name), $SMake::Model::Const::SOURCE_RESOURCE, $task);
  }
  
  return undef;
}

return 1;
