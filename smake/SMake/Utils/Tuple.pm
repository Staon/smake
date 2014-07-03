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

# Helper functions to work with key tuples
package SMake::Utils::Tuple;

# Compare two tuples
#
# Usage: isEqual($t1, $t2)
#    t1 ..... first tuple
#    t2 ..... second tuple
# Returns: true if the tuples are equal
sub isEqual {
  my ($t1, $t2) = @_;
  
  # -- check sizes
  return 0 if($#$t1 != $#$t2);
  
  # -- compare values
  for(my $index = 0; $index <= $#$t1; ++$index) {
    return 0 if($t1->[$index] ne $t2->[$index]);
  }
  
  return 1;
}

return 1;
