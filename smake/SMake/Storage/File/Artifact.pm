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

# Implementation of the Artifact object for the file storage
package SMake::Storage::File::Artifact;

use SMake::Model::Artifact;

@ISA = qw(SMake::Model::Artifact);

use SMake::Storage::File::Resource;
use SMake::Storage::File::Stage;

# Create new artifact object
#
# Usage: new($repository, $storage, $project, $path, $name, $type, \%args)
#    repository .... a repository which the artifact belongs to
#    storage ....... owning file storage
#    project ....... a project which the artifact belongs to
#    path .......... canonical location (directory) of the artifact
#    name .......... name of the artifact
#    type .......... type of the artifact
#    args .......... optional artifact's arguments
sub new {
  my ($class, $repository, $storage, $project, $path, $name, $type, $args) = @_;
  my $this = bless(SMake::Model::Artifact->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{project} = $project;
  $this->{path} = $path;
  $this->{name} = $name;
  $this->{type} = $type;
  $this->{args} = $args;
  $this->{descriptions} = {};
  $this->{resources} = {};
  $this->{stages} = {};
  return $this;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getKey {
  my ($this) = @_;
  return $this->getName();
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getType {
  my ($this) = @_;
  return $this->{type};
}

sub getArguments {
  my ($this) = @_;
  return $this->{args};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getProject {
  my ($this) = @_;
  return $this->{project};
}

sub attachDescription {
  my ($this, $description) = @_;
  $this->{descriptions}->{$description->getKey()} = 1;
}

sub createResource {
  my ($this, $prefix, $name, $type) = @_;
  my $resource = SMake::Storage::File::Resource->new(
      $this->{repository}, $this->{storage}, $this->{path}, $prefix, $name, $type);
  $this->{resources}->{$resource->getKey()} = $resource;
  return $resource;
}

sub createStage {
  my ($this, $name) = @_;
  my $stage = $this->{stages}->{$name};
  if(!defined($stage)) {
    $stage = SMake::Storage::File::Stage->new(
        $this->{repository}, $this->{storage}, $this, $name);
    $this->{stages}->{$stage->getKey()} = $stage;
  }
  return $stage;
}

return 1;
