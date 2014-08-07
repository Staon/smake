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

use SMake::Model::Dependency;
use SMake::Model::Stage;
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
  $this->{dependencies} = {};
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
  foreach my $resource (values %{$this->{resources}}) {
    $resource->destroy();
  }
  $this->{resources} = undef;
  foreach my $stage (values %{$this->{stages}}) {
    $stage->destroy();
  }
  $this->{stages} = undef;
  foreach my $dep (values %{$this->{dependencies}}) {
    $dep->destroy();
  }
  $this->{dependencies} = undef;
}

# Usage: update($path, $type, \%args)
#    path ..... logical path of the artifact
#    type ..... type of the artifact
#    args ..... artifact's arguments
sub update {
  my ($this, $path, $type, $args) = @_;

  $this->{path} = $path;
  $this->{type} = $type;
  $this->{args} = $args;  
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
  my ($this, $type, $name, $location, $task) = @_;

  my $resource = SMake::Storage::File::Resource->new(
      $this->{repository},
      $this->{storage},
      $this,
      $this->{path},
      $type,
      $name,
      $location,
      $task);
  $this->{resources}->{$resource->getKey()} = $resource;
  return $resource;
}

sub getResource {
  my ($this, $type, $name) = @_;
  return $this->{resources}->{SMake::Model::Resource::createKey($type, $name)};
}

sub getResourceKeys {
  my ($this) = @_;
  return [map { [$_->getType(), $_->getName()] } values(%{$this->{resources}})];
}

sub deleteResources {
  my ($this, $list) = @_;
  
  foreach my $tuple (@$list) {
    my $key = SMake::Model::Resource::createKey(@$tuple);
    $this->{resources}->{$key}->destroy();
    delete $this->{resources}->{$key};
  }
}

sub getResources {
  my ($this) = @_;
  return [values %{$this->{resources}}];
}

sub setMainResources {
  my ($this, $default, $map) = @_;
  
  $this->{main} = $default;
  $this->{main_resources} = $map;
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
  $this->{stages}->{$stage->getKey()} = $stage;
  return $stage;
}

sub getStage {
  my ($this, $name) = @_;
  return $this->{stages}->{SMake::Model::Stage::createKey($name)};
}

sub getStageKeys {
  my ($this) = @_;
  return [map {$_->getKeyTuple()} (values %{$this->{stages}})];
}

sub deleteStages {
  my ($this, $list) = @_;
  
  foreach my $stage (@$list) {
    my $key = SMake::Model::Stage::createKey(@$stage);
    $this->{stages}->{$key}->destroy();
    delete $this->{stages}->{$key};
  }
}

sub getStages {
  my ($this) = @_;
  return [values %{$this->{stages}}];
}

sub createDependency {
  my ($this, $depkind, $deptype, $depprj, $departifact, $maintype) = @_;
  
  my $dependency = SMake::Storage::File::Dependency->new(
      $this->{repository},
      $this->{storage},
      $this,
      $depkind,
      $deptype,
      $depprj,
      $departifact,
      $maintype);
  $this->{dependencies}->{$dependency->getKey()} = $dependency;
  return $dependency;
}

sub getDependency {
  my $this = shift;
  return $this->{dependencies}->{SMake::Model::Dependency::createKey(@_)};
}

sub getDependencyKeys {
  my ($this) = @_;
  return [map {$_->getKeyTuple()} values %{$this->{dependencies}}];
}

sub deleteDependencies {
  my ($this, $list) = @_;
  
  foreach my $dep (@$list) {
    my $key = SMake::Model::Dependency::createKey(@$dep);
    $this->{dependencies}->{$key}->destroy();
    delete $this->{dependencies}->{$key};
  }
}

sub getDependencyRecords {
  my ($this) = @_;
  return [values %{$this->{dependencies}}];
}

sub searchResource {
  my ($this, $restype, $path, $location) = @_;

  print "$restype " . $path->asString() . "$location\n";

  foreach my $resource (values %{$this->{resources}}) {
  	
  	print "  " . $resource->getType() . " " . $resource->getName()->asString() . " " . $resource->getLocation() . "\n";
  	
    if($resource->getType() =~ /$restype/
       && $resource->getName()->asString() eq $path->asString()
       && $resource->getLocation() =~ /$location/) {
      return $resource;
    }
  }
  return undef;
}

return 1;
