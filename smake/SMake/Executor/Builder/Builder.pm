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

# Generic interface of command builders
package SMake::Executor::Builder::Builder;

use SMake::Executor::Command::Resource;
use SMake::Executor::Const;
use SMake::Executor::Executor;
use SMake::Model::Const;
use SMake::Utils::Abstract;

# Create new command builder
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Build command tree for specified task
#
# Usage: build($context, $task)
#    context ..... executor context
#    task ........ the task
# Returns: \@commands ... list of constructed abstract commands
sub build {
  SMake::Utils::Abstract::dieAbstract();
}

# A helper method - get physical path of a resource
#
# Usage: getResourcePath($context, $resource)
# Returns: the physical path
sub getResourcePath {
  my ($this, $context, $resource) = @_;
  return $context->getRepository()->getPhysicalPathObject($resource->getPath());
}

# A helper method - create resource node of a resource
#
# Usage: createResourceNode($context, $resource)
# Returns: the node
sub createResourceNode {
  my ($this, $context, $resource) = @_;
  return SMake::Executor::Command::Resource->new(
      $this->getResourcePath($context, $resource));
}

# A builder function - add target resources into a logical command
#
# Usage: addTargetResources($context, $task, $command)
#    context ...... Executor context
#    task ......... Task object
#    command ...... Root of the logical command (a Command::Set)
sub addTargetResources {
  my ($this, $context, $task, $command) = @_;
  
  # -- target resources
  my $production = SMake::Executor::Command::Group->new(
      $SMake::Executor::Const::PRODUCT_GROUP);
  $command->putChild($production);
  foreach my $resource (@{$task->getTargets()}) {
    $production->appendChild($this->createResourceNode($context, $resource));
  }
}

# A builder function - add source resources into a logical command
#
# Usage: addTargetResources($context, $task, $command)
#    context ...... Executor context
#    task ......... Task object
#    command ...... Root of the logical command (a Command::Set)
sub addSourceResources {
  my ($this, $context, $task, $command) = @_;
  
  # -- source resources
  my $sources = SMake::Executor::Command::Group->new(
      $SMake::Executor::Const::SOURCE_GROUP);
  $command->putChild($sources);
  foreach my $resource (@{$task->getSources()}) {
    my $restype = $resource->getType();
    if($restype eq $SMake::Model::Const::SOURCE_RESOURCE
       || $restype eq $SMake::Model::Const::PRODUCT_RESOURCE) {
      $sources->appendChild($this->createResourceNode($context, $resource));
    }
  }
}

# A builder function - add source and target resources into a logical command
#
# Usage: addTargetResources($context, $task, $command)
#    context ...... Executor context
#    task ......... Task object
#    command ...... Root of the logical command (a Command::Set)
sub addResources {
  my ($this, $context, $task, $command) = @_;
  $this->addTargetResources($context, $task, $command);
  $this->addSourceResources($context, $task, $command);
}

sub addDependencies {
  my ($this, $context, $task, $command, $group, $deptype) = @_;

  my $groupnode = $command->getChild($group);
  if(!defined($groupnode)) {
    $groupnode = SMake::Executor::Command::Group->new($group);
    $command->putChild($groupnode);
  }
  
  my $deps = $task->getDependencies();
  foreach my $dep (@$deps) {
    if($dep->getDependencyType() eq $deptype) {
      my ($depprj, $depart, $stage, $depres) = $dep->getObjects(
          $context, $SMake::Executor::Executor::SUBSYSTEM);
      $groupnode->appendChild($this->createResourceNode($context, $depres));
    }
  }
}

# A builder function - add group of libraries computed from artifact's
#    dependencies
#
# Usage: addLibraries($context, $task, $command)
#    context ...... Executor context
#    task ......... Task object
#    command ...... Root of the logical command (a Command::Set)
sub addLibraries {
  my ($this, $context, $task, $command) = @_;
  $this->addDependencies(
      $context,
      $task,
      $command,
      $SMake::Executor::Const::LIB_GROUP,
      $SMake::Model::Const::LINK_DEPENDENCY);
}

# A builder function - add group of libraries to be installed
#
# Usage: addLibInstalls($context, $task, $command)
#    context ...... Executor context
#    task ......... Task object
#    command ...... Root of the logical command (a Command::Set)
sub addLibInstalls {
  my ($this, $context, $task, $command) = @_;
  $this->addDependencies(
      $context,
      $task,
      $command,
      $SMake::Executor::Const::SOURCE_GROUP,
      $SMake::Model::Const::LINK_DEPENDENCY);
}

return 1;
