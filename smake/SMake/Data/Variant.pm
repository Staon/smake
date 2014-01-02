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

# Generic identifier of a variant
package SMake::Data::Variant;

use SMake::Utils::Abstract;

# Create new variant object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Get hash key of the variant
sub hashKey {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a printable string representation
sub printString {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
