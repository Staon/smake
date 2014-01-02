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

#  Several utilities
package SMake::Utils::Utils;

#  This method check an argument. If the argument is a reference
#  to an array it returns the argument directly. When it's another
#  type, it creates an array which contains the value.
sub getArrayRef {
  return undef if(!defined($_[0]));
  return $_[0] if(ref($_[0]) eq "ARRAY");
  return [$_[0]];
}

# Die the process but report the error before
#
# Usage: myDie($reporter, $subsystem, $format, ...)
sub dieReport {
  my ($reporter, $subsystem, $format) = splice(@_, 0, 3);
  my $message = sprintf($format, @_);
  $reporter->report(1, "critical", $subsystem, $message);
  die "$message";
}

return 1;
