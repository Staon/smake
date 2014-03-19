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

# Resource command option
package SMake::Executor::Command::Resource;

use SMake::Executor::Command::Node;

@ISA = qw(SMake::Executor::Command::Node);

# Create new resource command node
#
# Usage: new($resource)
sub new {
  my ($class, $resource) = @_;
  my $this = bless(SMake::Executor::Command::Node->new(), $class);
  $this->{resource} = $resource;
}

sub getName {
  my ($this) = @_;
  return $this->{resource}->getKey();
}

# Get the resource
sub getResource {
  my ($this) = @_;
  return $this->{resource};
}

# Get physical path of the resource
#
# Usage: getPhysicalPath($repository)
sub getPhysicalPath {
  my ($this, $repository) = @_;
  return $repository->getPhysicalPath($this->{resource}->getPath());
}

return 1;
