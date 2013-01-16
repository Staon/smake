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

#  Generic source scanner
package SBuild::Scanner;

#  Ctor
sub newScanner {
	my $class = $_[0];
	my $this = {};
	bless $this, $class;
}

#  Scan a source file for dependencies
#
#  Usage: scanFile($profile, $reporter, $file)
sub scanFile {
	die "It's not possible to invoke a pure virtual method Scanner::scanFile!";
}

return 1;
