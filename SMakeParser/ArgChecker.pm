# Copyright (C) 2013 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is free software: you can redistribute it and/or modify
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

package SMakeParser::ArgChecker;

#  Usage: checkScalar($arg, $argname, $directive)
sub checkScalar {
	if(ref($_[0])) {
		die "Argument $_[1] of the directive $_[2] must be a scalar (a string or a number).";
	}
}

#  Usage: checkOptScalar($arg, $argname, $directive)
sub checkOptScalar {
	if(defined($_[0])) {
		checkScalar(@_);
	}
}

#  Usage: checkArray($arg, $argname, $directive)
sub checkArray {
	if(ref($_[0]) ne "ARRAY") {
		die "Argument $_[1] of the directive $_[2] must be an array - a list of values enclosed by \[\].";
	}
}

#  Usage: checkOptArray($arg, $argname, $directive)
sub checkOptArray {
	if(defined($_[0])) {
		checkArray(@_);
	}
}

#  Usage: checkHash($arg, $argname, $directive)
sub checkHash {
	if(ref($_[0]) ne "HASH") {
		die "Argument $_[1] of the directive $_[2] must be an array of arguments - a list of tuples 'key => value'.";
	}
}

#  Usage: checkOptScalar($arg, $argname, $directive)
sub checkOptHash {
	if(defined($_[0])) {
		checkHash(@_);
	}
}

#  Usage: checkScalarOrArray($arg, $argname, $directive)
sub checkScalarOrArray {
	if(ref($_[0]) && ref($_[0] ne "ARRAY")) {
		die "Argument $_[1] of the directive $_[2] must be a scalar or an array.";	
	}
}

return 1;
