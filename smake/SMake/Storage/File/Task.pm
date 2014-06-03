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

# Implementation of the task object for the external repository
package SMake::Storage::File::Task;

use SMake::Model::Task;

@ISA = qw(SMake::Model::Task);

use SMake::Data::Path;
use SMake::Storage::File::Timestamp;

# Create new task object
#
# Usage: new($repository, $storage, $stage, $taskid, $type, $wd, \%args)
sub new {
  my ($class, $repository, $storage, $stage, $taskid, $type, $wd, $args) = @_;
  my $this = bless(SMake::Model::Task->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{stage} = $stage;
  $this->{taskid} = $taskid;
  $this->{type} = $type;
  $this->{wdir} = SMake::Data::Path->new($wd);
  $this->{args} = defined($args)?$args:{};
  $this->{targets} = {};
  $this->{sources} = {};
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
  $this->{stage} = undef;
  foreach my $timestamp (values %{$this->{targets}}) {
    $timestamp->destroy();
  }
  foreach my $timestamp (values %{$this->{sources}}) {
    $timestamp->destroy();
  }
  $this->{dependencies} = undef;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getKey {
  my ($this) = @_;
  return $this->{taskid};
}

sub getType {
  my ($this) = @_;
  return $this->{type};
}

sub getArguments {
  my ($this) = @_;
  return $this->{args};
}

sub getStage {
  my ($this) = @_;
  return $this->{stage};
}

sub getWDPath {
  my ($this) = @_;
  return $this->{wdir};
}

sub appendTarget {
  my ($this, $resource) = @_;
  $this->{targets}->{$resource->getKey()} = SMake::Storage::File::Timestamp->new(
      $this->{repository}, $this->{storage}, $this, $resource);
}

sub getTargets {
  my ($this) = @_;
  return [map { $_->getResource() } values(%{$this->{targets}})];
}

sub appendSource {
  my ($this, $resource) = @_;
  $this->{sources}->{$resource->getKey()} = SMake::Storage::File::Timestamp->new(
      $this->{repository}, $this->{storage}, $this, $resource);
}

sub getSources {
  my ($this) = @_;
  return [map { $_->getResource() } values(%{$this->{sources}})];
}

sub getSourceTimestamps {
  my ($this) = @_;
  return [values(%{$this->{sources}})];
}

sub appendDependency {
  my ($this, $dependency) = @_;
  push @{$this->{dependencies}}, $dependency;
}

sub getDependencies {
  my ($this) = @_;
  return [@{$this->{dependencies}}];
}

sub getDependentTasks {
  my ($this, $reporter, $subsystem) = @_;
  
  my $list = [];
  foreach my $source (values %{$this->{sources}}) {
  	my $srctask = $source->getResource()->getTask();
  	# -- not external resource and dependencies inside the stage
  	if(defined($srctask)
  	   && ($this->{stage}->getKey() eq $srctask->getStage()->getKey())) {
      push @$list, $srctask->getKey(); 
    }
  }
  return $list;
}

return 1;
