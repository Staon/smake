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

# Create new task object
#
# Usage: new($repository, $storage, $stage, $type, \%args)
sub new {
  my ($class, $repository, $storage, $stage, $type, $args) = @_;
  my $this = bless(SMake::Model::Task->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{stage} = $stage;
  $this->{type} = $type;
  $this->{args} = defined($args)?$args:{};
  $this->{targets} = {};
  $this->{sources} = {};
   
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
  $this->{sources} = undef;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
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

sub appendTarget {
  my ($this, $resource) = @_;
  $this->{targets}->{$resource->getKey()} = $resource;
}

sub appendSource {
  my ($this, $resource) = @_;
  $this->{sources}->{$resource->getKey()} = $resource;
}

sub getSources {
  my ($this) = @_;
  return [values(%{$this->{sources}})];
}

return 1;
