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

use SMake::Update::Artifact;

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
  my $project = $context->getRepository()->getProject($name);
  if(defined($project)) {
    $project->update($path);
    
    # -- get list of artifacts
    $this->{artifacts} = {map {$_ => 0} @{$project->getArtifactNames()}};
  }
  else {
    $project = $context->getRepository()->createProject($name, $path);
    $this->{artifacts} = {};
  }
  $this->{project} = $project;
  
  return $this;
}

# Update data of the project and destroy current object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;

  # -- update artifacts and construct list of deleted
  my $to_delete = [];
  foreach my $artifact (keys %{$this->{artifacts}}) {
  	my $object = $this->{artifacts}->{$artifact};
    if($object) {
      $object->update($context);
    }
    else {
      push @$to_delete, $artifact;
    }
  }
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

# Get name of the project
sub getName {
  my ($this) = @_;
  return $this->{project}->getName();
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
  $this->{artifacts}->{$name} = $artifact;
  
  return $artifact;
}

return 1;
