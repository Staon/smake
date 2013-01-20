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

#  Relative directory path
package SBuild::DirectoryRelative;

use SBuild::Directory;

@ISA = qw(SBuild::Directory);

use SBuild::DirectoryAbsolute;
use SBuild::Dirutils;

use File::Spec;

# Ctor
#
# Usage: new($relative_path)
sub newDirectory {
	my $class = $_[0];
	my $this = SBuild::Directory->newDirectory;
	$this->{path} = $_[1];
	return bless $this, $class;
}

#  Check if the directory is an absolute path
sub isAbsolute {
	return 0;
}

#  Get absolute path
#
#  Usage: getAbsolute($base)
sub getAbsolute {
	my $this = $_[0];
	my $base = $_[1];
	return $base->absoluteFromRelative($this);
}

sub absoluteFromRelative {
	my $this = $_[0];
	my $path = $this->{path};
	die "Relative path $path cannot be used as a base path to compute an absolute path.";
}

#  Get string representation of the directory
sub getPath {
	my $this = $_[0];
	return $this->{path};
}

#  Compute relative difference between two directories
#
#  Usage: computeDifference($tg_dir)
sub computeDifference {
	die "It's not possible to compute difference between relative paths";
}

sub differenceFromAbsolute {
	die "It's not possible to compute difference between relative paths";
}

#  Append a path
#
#  Usage: appendPath($dir)
sub appendPath {
	my $this = $_[0];
	my $dir = $_[1];
	return $dir->appendPathFromRelative($this);
}

sub appendPathFromAbsolute {
	my $path = $_[0];
	my $base = $_[1];

	my $basepath = SBuild::Dirutils::canonizePath($base->getPath);
	my $appended = File::Spec->catdir($basepath, $path->{path});
	return SBuild::DirectoryAbsolute->newDirectory(SBuild::Dirutils::canonizePath($appended));
}

sub appendPathFromRelative {
	my $path = $_[0];
	my $base = $_[1];

	my $basepath = SBuild::Dirutils::canonizePath($base->getPath);
	my $appended = File::Spec->catdir($basepath, $path->{path});
	return SBuild::DirectoryRelative->newDirectory(SBuild::Dirutils::canonizePath($appended));
}

return 1;
