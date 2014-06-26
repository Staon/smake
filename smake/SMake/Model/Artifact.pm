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

# Update attributes of the object
#
# Usage: update($path, $type, \%args)
#    path ..... logical path of the artifact
#    type ..... type of the artifact
#    args ..... artifact's arguments
sub update {
  SMake::Utils::Abstract::dieAbstract();
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

# Create new resource
#
# Usage: createResource($name, $type, $task)
#    name ...... name of the resource (relative path based on the artifact)
#    type ...... type of the resource
#    task ...... a task which generates this resource
sub createResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get resource
#
# Usage: getResource($path)
# Returns: undef or the resource
sub getResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of strings which represent artifact's resources
#
# Usage: getResourceNames()
# Returns: \@list
sub getResourceNames {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete specified resources
#
# Usage: deleteResources(\@list)
#    list .... list of resource names (relative paths)
sub deleteResources {
  SMake::Utils::Abstract::dieAbstract();
}

# Set map of main resources
#
# Usage: setMainResources($default, \%map)
#    default .. default main resource
#    map ...... map of tuples (type => resource)
sub setMainResources {
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

# Create new stage
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

# Get list of stage names
#
# Usage: getStageNames()
# Returns: \@list
sub getStageNames {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of stages
#
# Usage: deleteStages(\@list)
#    list ..... list of stage names
sub deleteStages {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new dependency
#
# Usage: createDependency($deptype, $depprj, $departifact, $maintype)
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    maintype ...... type of the main resource
sub createDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get dependency object
#
# Usage: getDependency($deptype, $depprj, $departifact, $maintype)
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    maintype ...... type of the main resource
sub getDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of keys of dependency objects
#
# Usage: getDepKeys()
# Returns: \@list
sub getDepKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of dependencies
#
# Usage: deleteDependencies(\@list)
#    list ...... list of key strings
sub deleteDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of dependency objects
#
# Usage: getDependencyRecords()
# Returns: \@list
sub getDependencyRecords {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
