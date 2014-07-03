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

#  Utilities to work with directory paths
package SMake::Utils::Dirutils;

my $Is_QNX = $^O eq 'qnx';

use File::Spec;
use File::Path;
use File::Basename;

if($Is_QNX) {
  require QNX4;
}
else {
  require Cwd;
}

# Get current working directory
#
# Usage: getCwd([path])
#
#   When the path is specified, the function returns its absolute
#   path.
sub getCwd {
	my $path;
	if(defined($_[0])) {
		$path = $_[0];
	}
	else {
		if($Is_QNX) {
			$path = QNX4::cwd();
		}
		else {
			$path = Cwd::getcwd();
		}
	}
	# -- canonize the path
	if($Is_QNX) {
		return QNX4::canonical_path($path);
	}
	else {
		return Cwd::abs_path($path)
	}
}

#  Split directory path into parts
#
#  Usage: splitDir($path);
#  Return: @dirlist
sub splitDir {
	my $path = $_[0];
	my @parts = split(/\//, $path);

	# -- absolute path	
	if($#parts >= 0 && $parts[0] eq '') {
		$parts[0] = '/';
	}
	return grep { ! /^\s*$/ } @parts;
}

#  Canonize a path
#
#  This method doesn't check real directories on the filesystem,
#  only updates a string
#
#  Usage: canonizePath($path)
sub canonizePath {
	my @parts = splitDir($_[0]);
	
	# -- remove '.' - current directories
	@parts = grep { $_ ne File::Spec->curdir() } @parts;
	# -- remove updir references
	my @retval = ();
	foreach my $part (@parts) {
		if($part eq File::Spec->updir()) {
			pop @retval;
		}
		else {
			push @retval, $part;
		}
	}
	my $path = File::Spec->catdir(@retval);
	$path = File::Spec->curdir() if($path eq '');
	return $path;
}

#  Check if a path is absolute
#
#  Usage: isAbsolute($path)
#  Return: truw when the path is absolute
sub isAbsolute {
	my @parts = splitDir($_[0]);
	return $parts[0] eq '/';
}

#  Create a directory and all missing parts
#
#  Usage: makeDirectory($path)
#  Return: empty string or error message
sub makeDirectory {
	my $path = $_[0];
	
	my $err = [];
	if($Is_QNX) {
		mkpath([$path], 1);
	}
	else {
		mkpath($path, { verbose => 1, error => \$err});
	}
	for my $diag (@$err) {
		my($file, $message) = each %$diag;
		return $message;
	}

	return '';
}

#  Remove a directory and all it's content
#
#  Usage: removeDirectory($path)
#  Return: empty string or error message
sub removeDirectory {
	my $path = $_[0];
	
	my $err = [];
	if($Is_QNX) {
		rmtree([$path], 1);
	}
	else {
		rmtree($path, { verbose => 1, error => \$err } );
	}
	for my $diag (@$err) {
		my($file, $message) = each %$diag;
		return $message;
	}
  
	return '';
}

#  Link a content of a directory to another directory
#
#  This method list all files in a directory and it makes links
#  to them in a target directory
#
#  Usage: linkDirectoryContent($tgdir, $srcdir [, $filter])
#  Return: false when the function fails.
sub linkDirectoryContent {
	my $tgdir = $_[0];
	my $srcdir = $_[1];
	my $filter = $_[2];
	
	# -- list the source directory
	return 0 if(! opendir(DIRHANDLE, $srcdir));
	my @files = grep { ! /^[.]/ } readdir(DIRHANDLE);
	if(defined($filter)) {
		@files = grep { ! /$filter/ } @files;
	}
	closedir(DIRHANDLE);
	
	# -- make links
	foreach my $file (@files) {
		my $srcpath = File::Spec->catfile($srcdir, $file);
		return 0 if(! SBuild::Dirutils::linkFile($tgdir, $srcpath));
	}
	
	return 1;
}

#  Link a fake file instead of all files in a directory
#
#  This method lists all files in a directory and makes links with
#  the same name to a file in the target directory.
#
#  Usage: linkFakeDirectoryContent($tgdir, $srcdir, $fakefile [, $filter])
#  Return: false when the function fails.
sub linkFakeDirectoryContent {
	my $tgdir = $_[0];
	my $srcdir = $_[1];
	my $fakefile = $_[2];
	my $filter = $_[3];

	# -- list the source directory
	return 0 if(! opendir(DIRHANDLE, $srcdir));
	my @files = grep { ! /^[.]/ } readdir(DIRHANDLE);
	if(defined($filter)) {
		@files = grep { ! /$filter/ } @files;
	}
	closedir(DIRHANDLE);
	
	# -- make links
	foreach my $file (@files) {
		my $tgpath = File::Spec->catfile($tgdir, $file);
		unlink($tgpath);
		return 0 if(! symlink($fakefile, $tgpath));
	}
	
	return 1;
}

# Link a file into a directory
#
# Usage: linkFile($tgpath, $srcpath)
#    tgpath ...... string path of the target (link name)
#    srcpath ..... string path of the source file (linked file)
# Returns: false when the function fails.
sub linkFile {
  my ($tgpath, $srcpath) = @_;

  unlink($tgpath);
  return symlink($srcpath, $tgpath);  
}

return 1;
