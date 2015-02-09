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

package SMake::Utils::ArgChecker;

# Usage: dieArgument($directive, $arg, $index, $comp, $type)
sub checkArgument {
  my ($directive, $arg, $index, $comp, $type) = @_;
  if(!&{$comp}($arg)) {
    my ($package, $file, $line) = caller(3);
    die "Argument $index of the directive '$directive' (at line $line) must be $type";
  }
}

#  Usage: checkScalar($directive, $arg, $index)
sub checkScalar {
  checkArgument(
      @_,
      sub { return defined($_[0]) && !ref($_[0]); },
      "a scalar (string or number)");
}


#  Usage: checkOptScalar($arg, $argname, $directive)
sub checkOptScalar {
  checkArgument($_[0], sub { return !defined($_[0]) || !ref($_[0]); }, $_[1], "a scalar (string or number)");
}

#  Usage: checkArray($arg, $argname, $directive)
sub checkArray {
  checkArgument(
      @_,
      sub { return defined($_[0]) && ref($_[0]) eq "ARRAY"; },
      "an array ([values...])");
}

#  Usage: checkOptArray($arg, $argname, $directive)
sub checkOptArray {
  checkArgument(
      @_,
      sub { return !defined($_[0]) || ref($_[0]) eq "ARRAY"; },
      "an array ([values...])");
}

#  Usage: checkHash($arg, $argname, $directive)
sub checkHash {
  checkArgument(
      @_,
      sub { return defined($_[0]) && ref($_[0]) eq "HASH"; },
      "an array of arguments({key => value...})");
}

#  Usage: checkOptScalar($arg, $argname, $directive)
sub checkOptHash {
  checkArgument(
      @_,
      sub { return !defined($_[0]) || ref($_[0]) eq "HASH"; },
      "an array of arguments({key => value...})");
}

#  Usage: checkScalarOrArray($arg, $argname, $directive)
sub checkScalarOrArray {
  checkArgument(
      @_,
      sub { return defined($_[0]) && (!ref($_[0]) || ref($_[0]) eq "ARRAY"); },
      "a scalar or an array");
}

return 1;
