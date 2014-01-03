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

# Generic model object
package SMake::Model::Object;

use SMake::Utils::Abstract;

# Create new object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Get repository which the object belongs to
sub getRepository {
  SMake::Utils::Abstract::dieAbstract();
}

# Get physical (absolute) path of object. This method works only for objects
# which define method getPath (get resource location).
sub getPhysicalPath {
  my ($this) = @_;
  return $this->getRepository()->getPhysicalPath($this->getPath());
}

return 1;
