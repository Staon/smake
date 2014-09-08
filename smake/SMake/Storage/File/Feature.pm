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

# Implementation of the feature object for the file storage
package SMake::Storage::File::Feature;

use SMake::Model::Feature;

@ISA = qw(SMake::Model::Feature);

use SMake::Model::DepSpec;
use SMake::Storage::File::DepSpec;

# Create new artifact object
#
# Usage: new($repository, $storage, $project, $artifact, $name)
#    repository .... a repository which the artifact belongs to
#    storage ....... owning file storage
#    artifact ...... the artifact object which the feature belongs to
#    name .......... name of the feature
sub new {
  my ($class, $repository, $storage, $artifact, $name) = @_;
  
  my $this = bless(SMake::Model::Feature->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{artifact} = $artifact;
  $this->{name} = $name;
  $this->{onlist} = {};
  $this->{offlist} = {};
  
  return $this;
}

# Destroy the object
sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{artifact} = undef;
  foreach my $dep (values %{$this->{onlist}}) {
    $dep->destroy();
  }
  $this->{onlist} = undef;
  foreach my $dep (values %{$this->{offlist}}) {
    $dep->destroy();
  }
  $this->{offlist} = undef;
}

sub update {
  my ($this) = @_; 
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

sub createOnDependency {
  my ($this, $type, $spec) = @_;
  
  my $specobj = SMake::Storage::File::DepSpec->new(
      $this->{repository}, $this->{storage}, $this, $type, $spec);
  $this->{onlist}->{$specobj->getKey()} = $specobj;
  return $specobj;
}

sub getOnDependency {
  my ($this, $type, $spec) = @_;
  return $this->{onlist}->{SMake::Model::DepSpec::createKey($type, $spec)};
}

sub getOnDependencyKeys {
  my ($this) = @_;
  return [map { $_->getKeyTuple() } values(%{$this->{onlist}})];
}

sub deleteOnDependencies {
  my ($this, $list) = @_;
  
  foreach my $tuple (@$list) {
    my $key = SMake::Model::DepSpec::createKey(@$tuple);
    $this->{onlist}->{$key}->destroy();
    delete $this->{onlist}->{$key};
  }
}

sub getOnDependencies {
  my ($this) = @_;
  return [values %{$this->{onlist}}];
}

sub createOffDependency {
  my ($this, $type, $spec) = @_;
  
  my $specobj = SMake::Storage::File::DepSpec->new(
      $this->{repository}, $this->{storage}, $this, $type, $spec);
  $this->{offlist}->{$specobj->getKey()} = $specobj;
  return $specobj;
}

sub getOffDependency {
  my ($this, $type, $spec) = @_;
  return $this->{offlist}->{SMake::Model::DepSpec::createKey($type, $spec)};
}

sub getOffDependencyKeys {
  my ($this) = @_;
  return [map { $_->getKeyTuple() } values(%{$this->{offlist}})];
}

sub deleteOffDependencies {
  my ($this, $list) = @_;
  
  foreach my $tuple (@$list) {
    my $key = SMake::Model::DepSpec::createKey(@$tuple);
    $this->{offlist}->{$key}->destroy();
    delete $this->{offlist}->{$key};
  }
}

sub getOffDependencies {
  my ($this) = @_;
  return [values %{$this->{offlist}}];
}

return 1;
