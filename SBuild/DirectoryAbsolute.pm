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

#  Absolute directory path
package SBuild::DirectoryAbsolute;

use SBuild::Directory;

@ISA = qw(SBuild::Directory);

use SBuild::DirectoryRelative;
use SBuild::Dirutils;

use File::Spec;

# Ctor
#
# Usage: new($absolute_path)
sub newDirectory {
	my $class = $_[0];
	my $this = SBuild::Directory->newDirectory;
	$this->{path} = $_[1];
	return bless $this, $class;
}

#  Check if the directory is an absolute path
sub isAbsolute {
	return 1;
}

#  Get absolute path
#
#  Usage: getAbsolute($base)
sub getAbsolute {
	my $this = $_[0];
	return SBuild::DirectoryAbsolute->newDirectory($this->{path});
}

sub absoluteFromRelative {
	my $base = $_[0];
	my $path = $_[1];
	
	my $abs = File::Spec->catdir($base->{path}, $path->getPath);
	return SBuild::DirectoryAbsolute->newDirectory(SBuild::Dirutils::canonizePath($abs));
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
	my $this = $_[0];
	my $tg_dir = $_[1];
	return $tg_dir->differenceFromAbsolute($this);
}

sub differenceFromAbsolute {
	my $target = $_[0];
	my $source = $_[1];

#	print "Difference: " . $source->{path} . " " . $target->{path} . "\n";
	
	# -- split paths to separated parts
	my @tglist = SBuild::Dirutils::splitDir($target->{path});
	my @srclist = SBuild::Dirutils::splitDir($source->{path});
	
	# -- find maximal shared path
	my $index = 0;
	while($index <= $#tglist && $index <= $#srclist &&
	      $srclist[$index] eq $tglist[$index]) {
#	    print "Part: " . $srclist[$index] . "\n";
		++ $index;
	}
	
	# -- if there is no a shared part use the absolute path
#	print "Index: $index\n";
	if($index == 1) {
		return SBuild::DirectoryAbsolute->newDirectory($target->{path});
	}
	
	# -- compose relative path
	my @relpath = ();
	for(my $i = $#srclist; $i >= $index; -- $i) {
		push @relpath, File::Spec->updir();
	}
	while($index <= $#tglist) {
		push @relpath, $tglist[$index];
		++ $index;
	}
	my $path = File::Spec->catdir(@relpath);
	return SBuild::DirectoryRelative->newDirectory($path);
}

#  Append a path
#
#  Usage: appendPath($dir)
sub appendPath {
	my $this = $_[0];
	my $dir = $_[1];
	return $dir->appendPathFromAbsolute($this);
}

sub appendPathFromAbsolute {
	my $path = $_[0];
	my $base = $_[1];
	
	return SBuild::DirectoryAbsolute->newDirectory(SBuild::Dirutils::canonizePath($path->{path}));
}

sub appendPathFromRelative {
	my $path = $_[0];
	my $base = $_[1];
	
	return SBuild::DirectoryAbsolute->newDirectory(SBuild::Dirutils::canonizePath($path->{path}));
}

return 1;
