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

use SMake::Storage::File::Dependency;
use SMake::Storage::File::Resource;
use SMake::Storage::File::Stage;

use Data::Dumper;

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
  $this->{resources} = {};
  $this->{stages} = {};
  $this->{main_resources} = {};
  $this->{main} = undef;
  $this->{dependencies} = [];
  return $this;
}

# Destroy the object (break cycles in references as the Perl uses reference counters)
#
# Usage: destroy()
sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{project} = undef;
  foreach my $resource (@{$this->{resources}}) {
    $resource->destroy();
  }
  $this->{resources} = undef;
  foreach my $stage (@{$this->{stages}}) {
    $stage->destroy();
  }
  $this->{stages} = undef;
  foreach my $dep (@{$this->{dependencies}}) {
    $dep->destroy();
  }
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

sub createResource {
  my ($this, $name, $type, $task) = @_;
  my $resource = SMake::Storage::File::Resource->new(
      $this->{repository}, $this->{storage}, $this, $this->{path}, $name, $type, $task);
  $this->{resources}->{$resource->getKey()} = $resource;
  return $resource;
}

sub getResource {
  my ($this, $path) = @_;
  return $this->{$path->hashKey()};
}

sub getResourceNames {
  my ($this) = @_;
  return [keys(%{$this->{resources}})];  
}

sub appendMainResource {
  my ($this, $type, $resource) = @_;
  
  # -- check existence of the resource
  my $r = $this->{resources}->{$resource->getKey()};
  if(!defined($r) || ($r != $resource)) {
    die "the main resource must be part of the artifact";
  }
  
  $this->{main_resources}->{$type} = $resource;
  if(!defined($this->{main})) {
    $this->{main} = $resource;
  }
}

sub getMainResource {
  my ($this, $type) = @_;
  return $this->{main_resources}->{$type};
}

sub getDefaultMainResource {
  my ($this) = @_;
  return $this->{main};
}

sub createStage {
  my ($this, $name) = @_;
  
  $stage = SMake::Storage::File::Stage->new(
      $this->{repository}, $this->{storage}, $this, $name);
  $this->{stages}->{$name} = $stage;
  return $stage;
}

sub getStage {
  my ($this, $name) = @_;
  return $this->{stages}->{$name};
}

sub createDependency {
  my ($this, $deptype, $depprj, $departifact) = @_;
  
  my $dependency = SMake::Storage::File::Dependency->new(
      $this->{repository}, $this->{storage}, $this, $deptype, $depprj, $departifact);
  push @{$this->{dependencies}}, $dependency;
  
  return $dependency;
}

sub getDependencyRecords {
  my ($this) = @_;
  return [@{$this->{dependencies}}];
}

sub searchResource {
  my ($this, $restype, $path) = @_;

  foreach my $resource (values %{$this->{resources}}) {
    if($resource->getType() =~ /$restype/
       && $resource->getRelativePath()->asString() eq $path->asString()) {
      return $resource;
    }
  }
  return undef;
}

return 1;
