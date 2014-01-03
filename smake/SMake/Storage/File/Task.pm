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
package SMake::Repository::External::Task;

use SMake::Model::Task;

@ISA = qw(SMake::Model::Task);

# Create new task object
#
# Usage: new($repository, $stage, $type, \%args)
sub new {
  my ($class, $repository, $stage, $type, $args) = @_;
  my $this = bless(SMake::Model::Task->new(), $class);
  $this->{repository} = $repository;
  $this->{stage} = $stage;
  $this->{type} = $type;
  $this->{args} = $args;
  
  return $this;
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

return 1;