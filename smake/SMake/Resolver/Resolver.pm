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

# Generic resolver interface
package SMake::Resolver::Resolver;

use SMake::Utils::Abstract;

# Create new resolver class
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Resolve a resource
#
# Usage: resolveResource($context, $resource)
#    context ..... parser context, project and artifact are valid
#    resource .... resolved resource
# Returns: true if the resource is handled
sub resolveResource {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
