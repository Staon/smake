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

# Implementation of the timestamp class for the file storage
package SMake::Storage::File::Timestamp;

use SMake::Model::Timestamp;

@ISA = qw(SMake::Model::Timestamp);

# Create new timestamp object
#
# Usage: new($repository, $storage, $task, $resource, $mark?)
sub new {
  my ($class, $repository, $storage, $task, $resource, $mark) = @_;
  my $this = bless(SMake::Model::Timestamp->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{task} = $task;
  $this->{resource} = $resource;
  $this->{mark} = $mark;
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{task} = undef;
  $this->{resource} = undef;
  $this->{mark} = undef;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getMark {
  my ($this) = @_;
  return $this->{mark};
}

sub updateMark {
  my ($this, $mark) = @_;
  return $this->{mark} = $mark;
}

sub getResource {
  my ($this) = @_;
  return $this->{resource};
}

return 1;
