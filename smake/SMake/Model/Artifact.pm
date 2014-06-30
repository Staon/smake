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

use SMake::Model::Dependency;
use SMake::Utils::Abstract;
use SMake::Utils::Print;

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

# Create key tuple (static)
#
# Usage: createKeyTuple($name)
sub createKeyTuple {
  return [$_[0]];
}

# Create a string key of the artifact (static)
#
# Usage: createKey($name)
sub createKey {
  return $_[0];
}

sub getKeyTuple {
  my ($this) = @_;
  return createKeyTuple($this->getName());
}

sub getKey {
  my ($this) = @_;
  return createKey($this->getName());
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
# Usage: getResource($type, $path)
# Returns: undef or the resource
sub getResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of strings which represent artifact's resources
#
# Usage: getResourceKeys()
# Returns: \@list of tuples [$type, $name]
sub getResourceKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete specified resources
#
# Usage: deleteResources(\@list)
#    list .... list of tuples ($type, $name)
sub deleteResources {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of resource objects
#
# Usage: getResources()
# Returns: \@list
sub getResources {
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
# Usage: getStageKeys()
# Returns: \@list of key tuples
sub getStageKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of stages
#
# Usage: deleteStages(\@list)
#    list ..... list of key tuples
sub deleteStages {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of stage objects
sub getStages {
  SMake::Utils::Abstract::dieAbstract();
}

# Create resource dependency
#
# Usage: createResourceDependency($deptype, $depprj, $departifact, $maintype)
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    maintype ...... type of the main resource
sub createResourceDependency {
  my ($this, $deptype, $depprj, $departifact, $maintype) = @_;
  return $this->createDependency(
      $SMake::Model::Dependency::RESOURCE_KIND,
      $deptype,
      $depprj,
      $departifact,
      $maintype);
}

# Create stage dependency
#
# Usage: createStageDependency($deptype, $depprj, $departifact, $depstage)
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
#    depstage ...... name of the dependency stage
sub createStageDependency {
  my ($this, $deptype, $depprj, $departifact, $depstage) = @_;
  return $this->createDependency(
      $SMake::Model::Dependency::STAGE_KIND,
      $deptype,
      $depprj,
      $departifact,
      $depstage);
}

# Create dependency
#
# Usage: createDependency($depkind, $deptype, $depprj, $departifact, ...)
#    depkind ....... kind of the dependency
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
sub createDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get dependency object
#
# Usage: getDependency($depkind, $deptype, $depprj, $departifact, ...)
#    depkind ....... kind of the dependency
#    deptype ....... dependency type
#    depprj ........ name of the dependency project
#    departifact ... name of the dependency artifact
sub getDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of keys of dependency objects
#
# Usage: getDepKeys()
# Returns: \@list list of key tuples
sub getDependencyKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of dependencies
#
# Usage: deleteDependencies(\@list)
#    list ...... list of key tuples
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

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Artifact(" . $this->getName() . ") {\n";
  
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "type: " . $this->getType() . "\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "path: " . $this->getPath()->asString() . "\n";
  
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "arguments: ";
  SMake::Utils::Print::printArguments($this->getArguments());
  print ::HANDLE "\n";
  
  # -- resources
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "resources: {\n";
  my $resources = $this->getResources();
  foreach my $res (@$resources) {
    SMake::Utils::Print::printIndent($indent + 2);
    $res->prettyPrint($indent + 1);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";
  
  # -- stages
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "stages: {\n";
  my $stages = $this->getStages();
  foreach my $stage (@$stages) {
    SMake::Utils::Print::printIndent($indent + 2);
    $stage->prettyPrint($indent + 2);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";
  
  # -- dependencies
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "dependencies: {\n";
  my $deps = $this->getDependencyRecords();
  foreach my $dep (@$deps) {
    SMake::Utils::Print::printIndent($indent + 2);
    $dep->prettyPrint($indent + 2);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";

  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
