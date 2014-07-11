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

# Project update object - this object allows to update data of a project
# according to currently parsed SMakefile
package SMake::Update::Project;

use SMake::Model::Artifact;
use SMake::Parser::Parser;
use SMake::Update::Artifact;
use SMake::Update::Table;

# Create new project object
#
# Usage: new($context, $name, $path)
#    context ...... parser context
#    name ......... name of the project
#    path ......... logical path of the project (meaning of the storage)
sub new {
  my ($class, $context, $name, $path) = @_;
  my $this = bless({}, $class);
  
  # -- get existing project or create new
  my $project = $context->getVisibility()->createProject(
      $context, $SMake::Parser::Parser::SUBSYSTEM, $name);
  
  # -- prepare update data
  $project->update($path);
  $this->{artifacts} = SMake::Update::Table->new(
      \&SMake::Model::Artifact::createKey,
      $project->getArtifactKeys());
  $this->{project} = $project;
  
  return $this;
}

# Update data of the project and destroy current object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;

  # -- update artifacts and construct list of deleted
  my ($to_delete, undef) = $this->{artifacts}->update($context);
  $this->{project}->deleteArtifacts($to_delete);
  
  # -- destroy the object
  $this->{artifacts} = undef;
  $this->{project} = undef;
}

# Get model project object
sub getObject {
  my ($this) = @_;
  return $this->{project};
}

# Get a string key
sub getKey {
  my ($this) = @_;
  return $this->{project}->getKey();
}

# Get name of the project
sub getName {
  my ($this) = @_;
  return $this->{project}->getName();
}

# Get path of the project. The path has a meaning in the context of the repository
sub getPath {
  my ($this) = @_;
  return $this->{project}->getPath();
}

# Create new artifact
#
# Usage: createArtifact($context, $path, $name, $type, \%args)
#    context ...... parser context
#    path ......... logical (storage meaning) path of the artifact
#    name ......... name of the artifact
#    type ......... type of the artifact (string, for example "lib", "bin", etc.)
#    args ......... optional artifact arguments
# Returns: the update artifact object
sub createArtifact {
  my ($this, $context, $path, $name, $type, $args) = @_;

  my $artifact = SMake::Update::Artifact->new(
      $context, $this, $path, $name, $type, $args);
  $this->{artifacts}->addItem($artifact);
  
  return $artifact;
}

# Get artifact
#
# Usage: getArtifact($name)
# Returns: the artifact or undef
sub getArtifact {
  my ($this, $name) = @_;
  return $this->{artifacts}->getItemByKey(
      SMake::Model::Artifact::createKey($name));
}

return 1;
