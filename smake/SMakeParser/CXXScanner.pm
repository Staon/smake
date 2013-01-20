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

#  Scanner of C++ sources
package SMakeParser::CXXScanner;

use SMakeParser::CppScanner;

@ISA = qw(SMakeParser::CppScanner);

#  Ctor
sub newScanner {
	my $class = $_[0];
	my $this = SMakeParser::CppScanner->newScanner;
	bless $this, $class;
}

#  Get options of the preprocessor
#
#  Usage: getOptions($profile)
#  Return: $options
sub getOptions {
	my $this = $_[0];
	my $profile = $_[1];
	return $profile->getProfileStack->getOptions("CXXCPPFLAGS", $profile);
}

return 1;
