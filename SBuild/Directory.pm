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

#  Generic directory description
package SBuild::Directory;

use SBuild::DirectoryAbsolute;
use SBuild::DirectoryRelative;
use SBuild::Dirutils;

use File::Spec;

# Ctor
sub newDirectory {
	my $class = $_[0];
	my $this = {};
	return bless $this, $class;
}

#  Check if the directory is an absolute path
sub isAbsolute {
	die "Pure virtual method: Directory::isAbsolute";
}

#  Get absolute path
#
#  Usage: getAbsolute($base)
sub getAbsolute {
	die "Pure virtual method: Directory::getAbsolute";
}

#  Get string representation of the directory
sub getPath {
	die "Pure virtual method: Directory::getPath";
}

#  Compute relative difference between two directories
#
#  Usage: computeDifference($tg_dir)
sub computeDifference {
	die "Pure virtual method: Directory::computeDifference";
}

#  Append a path
#
#  Usage: appendPath($dir)
sub appendPath {
	die "Pure virtual method: Directory::appendPath";
}

#  Append a filename and return string of the file path
#
#  Usage: appendFile($filename)
sub appendFile {
	my $this = $_[0];
	my $dir = $this->getPath;
	if($dir eq '') {
		return $_[1];
	}
	else {
		return File::Spec->catfile($dir, $_[1]);
	}
}

#  Factory function
#
#  Usage: createDirectory($path)
sub createDirectory {
	my $path = $_[0];

	if(SBuild::Dirutils::isAbsolute($path)) {
		# -- Remove node ID. It's a pitty thing but Perl doesn't handle these paths
		#    correctly. Important! The SMake doesn't support compilation on another
		#    node!
		$path =~ s/^\/\/[0-9]+//;
		return SBuild::DirectoryAbsolute->newDirectory($path);
	}
	else {
		return SBuild::DirectoryRelative->newDirectory($path);
	}
}

return 1;
