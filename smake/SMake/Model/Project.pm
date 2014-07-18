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

package SMake::Model::Project;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;
use SMake::Utils::Print;

# Create new project object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Update data of the project
#
# Usage: update($path)
sub update {
  SMake::Utils::Abstract::dieAbstract();
}

# Create key tuple
#
# Usage: createKeyTuple($name)
sub createKeyTuple {
  return [$_[0]];
}

# Create a string key of the project (static)
#
# Usage: createKey($name)
#    name ..... name of the project
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

# Get name of the project
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get path of the project. The path has a meaning in the context of the repository
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new artifact
#
# Usage: createArtifact($path, $name, $type, \%args)
#    path ..... logical (storage meaning) path of the artifact
#    name ..... name of the artifact
#    type ..... type of the artifact (string, for example "lib", "bin", etc.)
#    args ..... optional artifact arguments
sub createArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get artifact
#
# Usage: getArtifact($name)
# Returns: the artifact or undef
sub getArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of names of artifacts
#
# Usage: getArtifactKeys()
# Returns: \@list of tuples [$name (name of the project)]
sub getArtifactKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete specified artifacts
#
# Usage: deleteArtifacts(\@list)
#    list ..... list of tuples [$name]
sub deleteArtifacts {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of artifact objects
#
# Usage: getArtifacts()
# Returns: \@list
sub getArtifacts {
  SMake::Utils::Abstract::dieAbstract();
}

# Search for an external resource in the project
#
# Usage: searchResource($restype, $path)
#    restype ..... regular expression of searched resource types
#    path ........ relative path of the searched resource
# Returns: searched resource or undef
sub searchResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Install a resource into the installation area
#
# Usage: installResource($context, $subsystem, $resource)
#    context ...... executor context
#    subsystem .... logging subsystem
#    resource ..... the installed resource
sub installResource {
  my ($this, $context, $subsystem, $resource) = @_;

  $this->getRepository()->getInstallArea()->installResource(
      $context,
      $subsystem,
      $this,
      $resource);
}

# Install a dependency into the installation area
#
# Usage: installDependency($context, $subsystem, $dep)
#    context ...... executor context
#    subsystem .... logging subsystem
#    dep .......... the installed dependency
sub installDependency {
  my ($this, $context, $subsystem, $dep) = @_;
  
  $this->getRepository()->getInstallArea()->installDependency(
      $context,
      $subsystem,
      $this,
      $dep);
}  

# Get physical location of an installation module
#
# Usage: getModulePath($context, $subsystem, $module)
#    context ..... executor context
#    subsystem ... logging subsystem
#    module ...... installation module
# Returns: ($restype, $path)
#    restype ..... resource type of the path
#    path ........ the path (Data)
sub getModulePath {
  my ($this, $context, $subsystem, $module) = @_;

  return $this->getRepository()->getInstallArea()->getModulePath(
      $context,
      $subsystem,
      $module,
      $this);
}

# Clean project's installation area
#
# Usage: cleanInstallArea($context, $subsystem)
#    context ..... executor context
#    subsystem ... logging subsystem
sub cleanInstallArea {
  my ($this, $context, $subsystem) = @_;
  
  $this->getRepository()->getInstallArea()->cleanArea(
      $context, $subsystem, $this);
}

# Print content of the project
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Project(" . $this->getName() . ") {\n";
  
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "path: " . $this->getPath()->asString() . "\n";

  # -- artifacts
  my $list = $this->getArtifacts();
  foreach my $art (@$list) {
    SMake::Utils::Print::printIndent($indent + 1);
    $art->prettyPrint($indent + 1);
    print ::HANDLE "\n";
  }
  
  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
