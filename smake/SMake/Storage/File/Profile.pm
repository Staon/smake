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

# Implementation of the profile object
package SMake::Storage::File::Profile;

use SMake::Model::Profile;

@ISA = qw(SMake::Model::Profile);

# Create new profile object
#
# Usage: new($repository, $storage, $task, $dump)
#    repository ..... a repository which the storage belongs to
#    storage ........ the storage
#    task ........... parent task object
#    dump ........... profile dump string
sub new {
  my ($class, $repository, $storage, $task, $dump) = @_;
  my $this = bless(SMake::Model::Profile->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{task} = $task;
  $this->{dumpstring} = $dump;
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
}

sub getDumpString {
  my ($this) = @_;
  return $this->{dumpstring};
}

return 1;
