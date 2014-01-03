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

# Implementation of the description object for external repository
package SMake::Repository::External::Description;

use SMake::Model::Description;

@ISA = qw(SMake::Model::Description);

# Create new description object
#
# Usage: new($repository, $project, $path, $mark)
#    repository ..... repository object
#    path ........... logical path of the description file
#    mark ........... current decider mark
sub new {
  my ($class, $repository, $path, $mark) = @_;
  my $this = bless(SMake::Model::Description->new(), $class);
  $this->{repository} = $repository;
  $this->{path} = $path;
  $this->{mark} = $mark;
  
  return $this;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getMark {
  my ($this) = @_;
  return $this->{mark};
}

return 1;
