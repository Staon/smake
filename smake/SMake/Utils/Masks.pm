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

# Functions to construct regular expression masks
package SMake::Utils::Masks;

# Create mask which matches one of the values
#
# Usage: createMask(@values)
# Returns: the mask
sub createMask {
  my (@values) = @_;
  
  my $mask = '^';
  my $first = 1;
  foreach my $value (@values) {
    if($first) {
      $first = 0;
    }
    else {
      $mask .= '|';
    }
    $mask .= quotemeta($value); 
  }
  $mask .= '$';
  return $mask;
}

# Create the mask for one value. If the value is undef or empty, the mask matches
# everything.
#
# Usage: createMaskOptional($value)
# Returns: the mask
sub createMaskOptional {
  my ($value) = @_;
  if($value) {
    return '^' . quotemeta($value) . '$';
  }
  else {
    return '.*';
  }
}

return 1;
