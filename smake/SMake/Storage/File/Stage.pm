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

# Implementation of the stage object for the file storage
package SMake::Storage::File::Stage;

use SMake::Model::Stage;

@ISA = qw(SMake::Model::Stage);

use SMake::Executor::Executor;
use SMake::Storage::File::Task;
use SMake::Utils::Utils;

# Create new stage object
#
# Usage: new($repository, $storage, $artifact, $name)
sub new {
  my ($class, $repository, $storage, $artifact, $name) = @_;
  my $this = bless(SMake::Model::Stage->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{artifact} = $artifact;
  $this->{name} = $name;
  $this->{tasks} = {};
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
  foreach my $task (values %{$this->{tasks}}) {
    $task->destroy();
  }
  $this->{tasks} = undef;
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

sub createTask {
  my ($this, $name, $type, $wd, $arguments) = @_;
  
  my $task = SMake::Storage::File::Task->new(
      $this->{repository},
      $this->{storage},
      $this,
      $name,
      $type,
      $wd,
      $arguments);
  $this->{tasks}->{$name} = $task;
  return $task;
}

sub getTask {
  my ($this, $name) = @_;
  return $this->{tasks}->{$name};
}

sub getTasks {
  my ($this) = @_;
  return [keys(%{$this->{tasks}})];
}

sub getDependencies {
  my ($this, $reporter, $subsystem) = @_;
  my $self = $this->getAddress();
  
  my %addresses = ();
  
  # -- dependencies defined by resources
  foreach my $task (values %{$this->{tasks}}) {
  	# -- source resources
    my $sources = $task->getSources();
    foreach my $source (@$sources) {
      # -- TODO: handle external resources
      my $address = $source->getStage()->getAddress();
      if(!$address->isEqual($self)) {
        $addresses{$address->getKey()} = $address;
      }
    }
    
    # -- external dependencies
    my $dependencies = $task->getDependencies();
    foreach my $dep (@$dependencies) {
      my ($project, $artifact, $resource) = $dep->getObjects(
          $reporter, $subsystem, $this->{repository});
      my $stage = $resource->getStage();
      my $address = $stage->getAddress();
      $addresses{$address->getKey()} = $address;
    }
  }
  
  return [values %addresses];
}

return 1;
