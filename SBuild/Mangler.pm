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

# Mangler of file names
package SBuild::Mangler;

use File::Spec;

#  Ctor
sub newMangler {
	my $class = $_[0];
	my $this = {};
	bless $this, $class;
}

#  Mangle name of a library
#
#  Usage: mangleLibrary($profile, $file)
#  Return: mangled name of the library
sub mangleLibrary {
	my $this = $_[0];
	my $profile = $_[1];
	my $name = $_[2];
	$name = $name . $this->{libsuffix} if(defined($this->{libsuffix}));
	return $name;
}

#  Set library name suffix
#
#  Usage: setLibSuffix($suffix)
sub setLibSuffix {
	my $this = $_[0];
	$this->{libsuffix} = $_[1];
}

return 1;
