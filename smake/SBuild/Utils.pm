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

#  Several utilities
package SBuild::Utils;

#  This method check an argument. If the argument is a reference
#  to an array it returns the argument directly. When it's another
#  type, it creates an array which contains the value.
sub getArrayRef {
	return undef if(! defined($_[0]));
	return $_[0] if(ref($_[0]) eq "ARRAY");
	return [$_[0]];
}

#  In specified string a sequence @project_name@ is searched and replaced
#  by its location.
#
#  Usage: parseProjectString($repository, $string)
sub parseProjectString {
	my ($repository, $string) = @_;
	while($string =~ /@([^@]+)@/) {
		# -- the sequence is found
		my $path = $repository->getProjectPath($1);
		$string =~ s/@[^@]+@/$path/;
	}
	return $string;
}

return 1;
