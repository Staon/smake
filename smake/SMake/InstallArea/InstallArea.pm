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

# Generic interface of the installation area
package SMake::InstallArea::InstallArea;

use SMake::Utils::Abstract;

# Create new installation area object
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Install an external resource
#
# Usage: installResource($context, $subsystem, $project, $resource)
#    context ..... executor context
#    subsystem ... logging subsystem
#    project ..... project object which the resource is installed in
#    resource .... installed external resource
sub installResource {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
