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

# Queue of resources prepared for resolving
package SMake::ToolChain::Constructor::Queue;

# Create new queue
#
# Usage: new(\@list)
#    list ..... initial list of resources
sub new {
  my ($class, $list) = @_;
  return bless([@$list], $class);
}

# Push a resource into the queue
#
# Usage: pushResource($resource...)
sub pushResource {
  my ($this, @resource) = @_;
  push @$this, @resource;
}

# Get and remove resource from the top of the queue
#
# Usage: getResource()
# Returns: the resource or undef
sub getResource {
  my ($this) = @_;
  my $resource = shift @$this;
  return $resource;
}

return 1;