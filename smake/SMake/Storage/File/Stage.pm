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

use SMake::Storage::File::Task;

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
  $this->{tasks} = [];
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
  foreach my $task (@{$this->{tasks}}) {
    $task->destroy();
  }
  $this->{tasks} = undef;
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

sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

sub createTask {
  my ($this, $type, $arguments) = @_;
  
  my $task = SMake::Storage::File::Task->new(
      $this->{repository}, $this->{storage}, $this, $type, $arguments);
  push @{$this->{tasks}}, $task;
  return $task;
}

sub getDependencies {
  my ($this) = @_;
  my $self = $this->getAddress();
  
  my %addresses = ();
  
  # -- dependencies defined by resources
  foreach my $task (@{$this->{tasks}}) {
    my $sources = $task->getSources();
    foreach my $source (@$sources) {
      my $address = $source->getStage()->getAddress();
      if(!$address->isEqual($self)) {
        $addresses{$address->getKey()} = $address;
      }
    }
  }

  # -- TODO: explicit dependencies
  
  return [values %addresses];
}

return 1;
