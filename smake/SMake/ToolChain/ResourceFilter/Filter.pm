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

# Generic resource filter. The filter is used to detect external resources
# which are part of the system tools (system headers)
package SMake::ToolChain::ResourceFilter::Filter;

use SMake::Utils::Abstract;

# Create new resource filter
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Should be an external resource filtered?
#
# Usage: filterResource($context, $resource)
#    context ...... executor context
#    resource ..... the resource
# Returns: true if the resource should be filtered.
sub filterResource {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
