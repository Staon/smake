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

#  Change directory and remember current
package SBuild::Chdir;

use SBuild::Dirutils;

#  Ctor
#
#  Usage: newChdir
sub newChdir {
	my $class = $_[0];
	my $this = {};
	bless $this, $class;
}

#  Change the directory
#
#  Usage: pushDir($newpath, $reporter)
#  Return: False when the operation fails
sub pushDir {
	my $this = $_[0];
	my $newpath = $_[1];
	my $reporter = $_[2];
	
	# store old path
	$this->{oldpath} = SBuild::Dirutils::getCwd();
	# change directory
	if(! chdir($newpath)) {
		$reporter->reportError("It's not possible to enter into the directory $newpath!");
		return 0;
	}
	return 1;
}

#  Get back into previous directory
#
#  Usage: popDir($reporter)
#  Return: False when the operation fails
sub popDir {
	my $this = $_[0];
	my $reporter = $_[1];
	
	# change directory
	if(! chdir($this->{oldpath})) {
		$reporter->reportError("It's not possible to enter into the directory " . $this->{oldpath} . "!");
		return 0;
	}
	return 1;
}

return 1;
