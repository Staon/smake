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

# Generic resource object
package SMake::Model::Resource;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new resource
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Update attributes of the resource
#
# Usage: update($task)
#    task ..... task which creates the resource
sub update {
  SMake::Utils::Abstract::dieAbstract();
}

# (static) create key tuple
#
# Usage: createKeyTuple($type, $name)
#    type ..... task type
#    name ..... name of the resource (relative path)
sub createKeyTuple {
  my ($type, $name) = @_;
  return [$type, $name];
}

# (static) create string key
#
# Usage: createKey($type, $name)
#    type ..... task type
#    name ..... name of the resource (relative path)
sub createKey {
  my ($type, $name) = @_;
  return $type . "@" . $name->hashKey();
}

sub getKeyTuple {
  my ($this) = @_;
  return createKeyTuple($this->getType(), $this->getName());
}

sub getKey {
  my ($this) = @_;
  return createKey($this->getType(), $this->getName());
}

# Get name of the resource
#
# The name is a Path object, which contains a relative path of the resource
# based on the artifact location. Or the name can be a relative path of an
# external resource. The path must be unique in the project.
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the resource
#
# For example type can be "file" for physical file, "install" for a resource
# which is created in the installation are etc.
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get logical path of the resource
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get artifact which the resource belongs to
sub getArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a project which the resource belong to.
sub getProject {
  my ($this) = @_;
  return $this->getArtifact()->getProject();
}

# Get task which is a creator of the resource
#
# Returns: the task or undef, if the resource is an external resource
sub getTask {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stage which the resource is created in
#
# Returns: the stage
sub getStage {
  my ($this) = @_;
  return $this->getTask()->getStage();
}

# Make the resource public
#
# Usage: publishResource()
sub publishResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Resource(" . $this->getType()
      . ", " . $this->getName()->asString() . ", " . $this->getPath()->asString() . ")";
}

return 1;
