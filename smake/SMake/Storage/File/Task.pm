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
# Usage: new($repository, $storage, $stage, $name, $type, $wd, \%args)
sub new {
  my ($class, $repository, $storage, $stage, $name, $type, $wd, $args) = @_;
  my $this = bless(SMake::Model::Task->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{stage} = $stage;
  $this->{name} = $name;
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
  $this->{targets} = undef;
  foreach my $timestamp (values %{$this->{sources}}) {
    $timestamp->destroy();
  }
  $this->{dependencies} = undef;
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

sub getWDPath {
  my ($this) = @_;
  return $this->{wdir};
}

sub setTargets {
  my ($this, $list) = @_;
  $this->{targets} = {map {$_->getKey() => $_} @$list};
}

sub getTargets {
  my ($this) = @_;
  return [values(%{$this->{targets}})];
}

# Get list of names of source resources
#
# Usage: getSourceNames()
# Returns: \@list
sub getSourceNames {
  my ($this) = @_;
  return [map {$_->getName()} values(%{$this->{sources}})];
}

# Delete list of source resources
#
# Usage: deleteSources(\@list)
#    list .... list of resource names (relative paths)
sub deleteSources {
  my ($this, $list) = @_;
  
  foreach my $src (@$list) {
    $this->{sources}->{$src->hashKey()}->destroy();
  }
  delete $this->{sources}->{map {$_->hashKey()} @$list};
}

sub getSources {
  my ($this) = @_;
  return [map { $_->getResource() } values(%{$this->{sources}})];
}

sub createSourceTimestamp {
  my ($this, $resource) = @_;
  my $ts = SMake::Storage::File::Timestamp->new(
      $this->{repository}, $this->{storage}, $this, $resource);
  $this->{sources}->{$resource->getKey()} = $ts;
  return $ts;
}

sub getSourceTimestamp {
  my ($this, $name) = @_;
  return $this->{sources}->{$name->hashKey()};
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
  	   && ($this->{stage}->getName() eq $srctask->getStage()->getName())) {
      push @$list, $srctask->getName(); 
    }
  }
  return $list;
}

return 1;
