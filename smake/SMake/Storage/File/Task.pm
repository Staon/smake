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
use SMake::Model::TaskDependency;
use SMake::Model::Timestamp;
use SMake::Storage::File::Profile;
use SMake::Storage::File::TaskDependency;
use SMake::Storage::File::Timestamp;

# Create new task object
#
# Usage: new($repository, $storage, $stage, $name, $type, $wdtype, $wd, \%args)
sub new {
  my ($class, $repository, $storage, $stage, $name, $type, $wdtype, $wd, $args) = @_;
  
  my $this = bless(SMake::Model::Task->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{stage} = $stage;
  $this->{name} = $name;
  $this->{type} = $type;
  $this->{wdtype} = $wdtype;
  $this->{wdir} = (defined($wd))?SMake::Data::Path->new($wd):undef;
  $this->{args} = defined($args)?$args:{};
  $this->{targets} = {};
  $this->{sources} = {};
  $this->{dependencies} = {};
  $this->{profiles} = [];
  $this->{force_run} = 0;
   
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
  $this->{targets} = undef;
  foreach my $timestamp (values %{$this->{sources}}) {
    $timestamp->destroy();
  }
  $this->{sources} = undef;
  foreach my $profile (@{$this->{profiles}}) {
    $profile->destroy();
  }
  $this->{profiles} = undef;
  $this->{dependencies} = undef;
}

sub update {
  my ($this, $type, $wdtype, $wd, $args) = @_;

  $this->{type} = $type;
  $this->{wdtype} = $wdtype;
  $this->{wdir} = (defined($wd))?SMake::Data::Path->new($wd):undef;
  $this->{args} = defined($args)?$args:{};
  $this->{profiles} = [];
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

sub getStage {
  my ($this) = @_;
  return $this->{stage};
}

sub getWDType {
  my ($this) = @_;
  return $this->{wdtype};
}

sub getWDPath {
  my ($this) = @_;
  return $this->{wdir};
}

sub getTargetKeys {
  my ($this) = @_;
  return [map {$_->getKeyTuple()} values(%{$this->{targets}})];
}

sub deleteTargets {
  my ($this, $list) = @_;
  
  foreach my $tg (@$list) {
    my $key = SMake::Model::Timestamp::createKey(@$tg);
    $this->{targets}->{$key}->destroy();
    delete $this->{targets}->{$key};
  }
}

sub getTargets {
  my ($this) = @_;
  return [map { $_->getResource() } values(%{$this->{targets}})];
}

sub createTargetTimestamp {
  my ($this, $resource) = @_;
  
  my $ts = SMake::Storage::File::Timestamp->new(
      $this->{repository}, $this->{storage}, $this, $resource);
  $this->{targets}->{$ts->getKey()} = $ts;
  return $ts;
}

sub getTargetTimestamp {
  my ($this, $type, $name) = @_;
  return $this->{targets}->{SMake::Model::Timestamp::createKey($type, $name)};
}

sub getTargetTimestamps {
  my ($this) = @_;
  return [values %{$this->{targets}}];
}

sub getSourceKeys {
  my ($this) = @_;
  return [map {$_->getKeyTuple()} values(%{$this->{sources}})];
}

sub deleteSources {
  my ($this, $list) = @_;
  
  foreach my $src (@$list) {
  	my $key = SMake::Model::Timestamp::createKey(@$src);
    $this->{sources}->{$key}->destroy();
    delete $this->{sources}->{$key};
  }
}

sub getSources {
  my ($this) = @_;
  return [map { $_->getResource() } values(%{$this->{sources}})];
}

sub createSourceTimestamp {
  my ($this, $resource) = @_;
  my $ts = SMake::Storage::File::Timestamp->new(
      $this->{repository}, $this->{storage}, $this, $resource);
  $this->{sources}->{$ts->getKey()} = $ts;
  return $ts;
}

sub getSourceTimestamp {
  my ($this, $type, $name) = @_;
  return $this->{sources}->{SMake::Model::Timestamp::createKey($type, $name)};
}

sub getSourceTimestamps {
  my ($this) = @_;
  return [values(%{$this->{sources}})];
}

sub getDependencyKeys {
  my ($this) = @_;
  return [map {$_->getKeyTuple()} values(%{$this->{dependencies}})];
}

sub createDependency {
  my ($this, $dependency, $instmodule) = @_;
 
  my $taskdep = SMake::Storage::File::TaskDependency->new(
          $this->{repository}, $this->{storage}, $this, $dependency, $instmodule);
  $this->{dependencies}->{$taskdep->getKey()} = $taskdep;
  print "create task dependency: " . $taskdep->getKey() . "\n";
  return $taskdep;
}

sub getDependency {
  my ($this, $depkey) = @_;
  
  my $key = SMake::Model::TaskDependency::createKey(@$depkey);
  print "get dependency $key\n";
  return $this->{dependencies}->{$key};
}

sub deleteDependencies {
  my ($this, $list) = @_;
  
  foreach my $dep (@$list) {
    my $key = SMake::Model::TaskDependency::createKey(@$dep);
    print "dep to delete: $key\n";
    $this->{dependencies}->{$key}->destroy();
    delete $this->{dependencies}->{$key};
  }
}

sub getDependencies {
  my ($this) = @_;
  return [values %{$this->{dependencies}}];
}

sub appendProfile {
  my ($this, $dump) = @_;
  
  my $profile = SMake::Storage::File::Profile->new(
      $this->{repository}, $this->{storage}, $this, $dump);
  push @{$this->{profiles}}, $profile;
}

sub getProfiles {
  my ($this) = @_;
  return [@{$this->{profiles}}];
}

sub getDependentTasks {
  my ($this, $context, $subsystem) = @_;
  
  my $list = [];
  foreach my $source (values %{$this->{sources}}) {
  	my $srctask = $source->getResource()->getTask();
  	# -- not external resource and dependencies inside the stage
  	if(defined($srctask)
  	   && ($this->{stage}->getName() eq $srctask->getStage()->getName())) {
      push @$list, $srctask->getName(); 
    }
  }
  return $list;
}

sub setForceRun {
  my ($this, $flag) = @_;
  $this->{force_run} = $flag;
}

sub isForceRun {
  my ($this) = @_;
  return $this->{force_run};
}

return 1;
