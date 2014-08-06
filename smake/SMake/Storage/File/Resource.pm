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

# Implementation of the resource object for the file storage
package SMake::Storage::File::Resource;

use SMake::Model::Resource;

@ISA = qw(SMake::Model::Resource);

# Create new resource
#
# Usage: new($repository, $storage, $artifact, $basepath, $type, $name, $location, $task)
#    repository ... a repository which the resource belongs to
#    storage ...... owning file storage
#    artifact ..... an artifact which the resource belongs to
#    basepath ..... path of the artifact
#    type ......... type of the resource (for example "src")
#    name ......... name of the resource (as a relative path based on the artifact)
#    location ..... resource location type
#    task ......... task which generates the resource
sub new {
  my ($class, $repository, $storage, $artifact, $basepath, $type, $name, $location, $task) = @_;
  my $this = bless(SMake::Model::Resource->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{artifact} = $artifact;
  $this->{type} = $type;
  $this->{name} = $name;
  $this->{path} = $basepath->joinPaths($name);
  $this->{location} = $location;
  $this->{task} = $task;
  return $this;
}

# Destroy the object (break cycles in references as the Perl uses reference counters)
#
# Usage: destroy()
sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{artifact} = undef;
  $this->{task} = undef;
}

sub update {
  my ($this, $location, $task) = @_;
  
  $this->{location} = $location;
  $this->{task} = $task;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getType {
  my ($this) = @_;
  return $this->{type};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

sub getLocation {
  my ($this) = @_;
  return $this->{location};
}

sub getTask {
  my ($this) = @_;
  return $this->{task};
}

sub publishResource {
  my ($this) = @_;
  $this->getProject()->registerPublicResource($this);
}

return 1;
