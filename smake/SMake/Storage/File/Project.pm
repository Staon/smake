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

# Implementation of the project object for the file storage
package SMake::Storage::File::Project;

use SMake::Model::Project;

@ISA = qw(SMake::Model::Project);

use SMake::Storage::File::Artifact;

# Create new project object
#
# Usage: new($repository, $storage, $name, $path)
#    repository .. the smake repository
#    storage ..... owning file storage
#    name ........ name of the project
#    path ........ logical project path
sub new {
  my ($class, $repository, $storage, $name, $path) = @_;
  my $this = bless(SMake::Model::Project->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{name} = $name;
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{artifacts} = {};
  $this->{publics} = {};
  $this->{locked} = 0;
  $this->{resource_index} = {};
  
  return $this;
}

# Destroy the object (break cycles in references as the Perl uses reference counters)
#
# Usage: destroy()
sub destroy {
  my ($this) = @_;
  
  if(!$this->{locked}) {
    foreach my $artifact (values %{$this->{artifacts}}) {
      $artifact->destroy();
    }
    $this->{repository} = undef;
    $this->{storage} = undef;
    $this->{resource_index} = undef;
  }
}

sub update {
  my ($this, $path) = @_;
  
  $this->{path} = $path;
  
  # -- clean table of public resources
  my $prjkey = $this->getKeyTuple();
  foreach my $resource (values %{$this->{publics}}) {
    $this->{storage}->unregisterPublicResource($resource, $prjkey);
  }
}

sub lock {
  my ($this, $locked) = @_;
  $this->{locked} = $locked;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub createArtifact {
  my ($this, $path, $name, $type, $args) = @_;
  
  my $artifact = SMake::Storage::File::Artifact->new(
      $this->getRepository(), $this->{storage}, $this, $path, $name, $type, $args);
  $this->{artifacts}->{$artifact->getKey()} = $artifact;
  return $artifact;
}

sub getArtifact {
  my ($this, $name) = @_;
  return $this->{artifacts}->{SMake::Model::Artifact::createKey($name)};
}

sub getArtifactKeys {
  my ($this) = @_;
  return [map {[$_->getName()]} values %{$this->{artifacts}}];
}

sub deleteArtifacts {
  my ($this, $list) = @_;

  foreach my $tuple (@$list) {
    my $key = SMake::Model::Artifact::createKey(@$tuple);
    $this->{artifacts}->{$key}->destroy();
    delete $this->{artifacts}->{$key};
  }
}

sub getArtifacts {
  my ($this) = @_;
  return [values %{$this->{artifacts}}];
}

sub searchResource {
  my ($this, $restype, $path, $location) = @_;

  my $list = $this->{resource_index}->{$path->asString()};
  if(defined($list)) {
    foreach my $resource (@$list) {
      if($resource->getType() =~ /$restype/
         && $resource->getLocation() =~ /$location/) {
        return $resource;
      }
    }
  }
  return undef;

#  foreach my $artifact (values %{$this->{artifacts}}) {
#    my $resource = $artifact->searchResource($restype, $path, $location);
#    return $resource if(defined($resource));
#  }
#  return undef;
}

sub cleanPublicResources {
  my ($this, $context, $subsystem) = @_;
  
  my $prjkey = $this->getKeyTuple();
  foreach my $reskey (values %{$this->{publics}}) {
    $this->{storage}->unregisterPublicResource($reskey, $prjkey);
  }
}

# Register public resource
#
# Usage: registerPublicResource($resource)
#    resource ...... the resource object
sub registerPublicResource {
  my ($this, $resource) = @_;
  
  my $reskey = $resource->getKeyTuple();
  $this->{publics}->{$resource->getKey()} = $resource->getKeyTuple();
  $this->{storage}->registerPublicResource($reskey, $this->getKeyTuple());
}

sub insertResourceIntoIndex {
  my ($this, $resource) = @_;

  # -- update search index
  my $name = $resource->getName()->asString();
  my $list = $this->{resource_index}->{$name};
  if(!defined($list)) {
    $list = [];
    $this->{resource_index}->{$name} = $list;
  }
  push @$list, $resource;
}

sub removeResourceFromIndex {
  my ($this, $resource) = @_;

  # -- update the resource index
  my $name = $resource->getName()->asString();
  my $list = $this->{resource_index}->{$name};
  $list = [grep { $_->getKey() ne $key } @$list];
  if($#$list >= 0) {
    $this->{resource_index}->{$name} = $list;
  }
  else {
    delete $this->{resource_index}->{$name};
  }
}

return 1;
