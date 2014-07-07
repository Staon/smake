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

# Implementation of the task dependency object for the file storage
package SMake::Storage::File::TaskDependency;

use SMake::Model::TaskDependency;

@ISA = qw(SMake::Model::TaskDependency);

# Create new dependency object
#
# Usage: new($repository, $storage, $task, $dependency, $instmodule)
#    repository ........ repository
#    storage ........... owner storage
#    task .............. task which the dependency belongs to
#    dependency ........ the dependency object
#    instmodule ........ installation module
sub new {
  my ($class, $repository, $storage, $task, $dependency, $instmodule) = @_;
  my $this = bless(SMake::Model::TaskDependency->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{task} = $task;
  $this->{dependency} = $dependency;
  $this->{instmodule} = $instmodule;
  
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{task} = undef;
  $this->{dependency} = undef;
  $this->{instmodule} = undef;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getTask {
  my ($this) = @_;
  return $this->{task};
}

sub getDependency {
  my ($this) = @_;
  return $this->{dependency};
}

sub getInstallModule {
  my ($this) = @_;
  return $this->{instmodule};
}

return 1;
