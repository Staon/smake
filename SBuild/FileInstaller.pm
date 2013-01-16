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

#  File installer
package SBuild::FileInstaller;

use File::Basename;
use File::Spec;
use File::Path;
use File::Copy;

#  Ctor
#
#  Usage: newFileInstaller($duplicate, $install)
sub newFileInstaller {
	my $class = $_[0];
	my $this = { 
		duplicate => $_[1]
	};
	
	if($_[2]) {
		$this->{instdir} = $_[2];
	}
	else {
		$this->{instdir} = $ENV{'SMAKE_INSTALL'};
	}
	
	bless $this, $class;
}

#  Install a file
#
#  The method installs a file $file into path $path. When the $path
#  is a relative path, content of environment variable SMAKE_INSTALL
#  is prepended.
#
#  All missing directories in paths are created
#
#  Usage: installFile($reporter, $project, $file, $path)
#  Return: false when the installation fails
sub installFile {
	my $this = $_[0];
	my $reporter = $_[1];
	my $project = $_[2];
	my $file = $_[3];
	my $path = $_[4];
	
	# -- prepend the $SYSDIR path
	if(! File::Spec->file_name_is_absolute($path)) {
		if(! $this->{instdir}) {
			$reporter->reportError("There is no installation directory specified!"); 
			return 0; 
		}
		$path = File::Spec->catdir($this->{instdir}, $path);
	}
	
	# -- create target directory if it's not existing
	if(! -d $path) {
		my $err;
		mkpath($path, { error => \$err } );
		foreach my $diag (@$diag) {
			my ($file, $message) = each %$diag;
			$reporter->reportError("Cannot create directory $file: $message");
			return 0;
		}
	}
	
	# -- name of the link
	my $purefile = fileparse($file);
	my $linkname = File::Spec->catfile($path, $purefile);
	# -- source name
	my $srcdir = $project->getPath;
	my $srcfile = File::Spec->catfile($srcdir, $file);
	# -- report installation task
	$reporter->reportInstall("Install file $srcfile to $linkname");
	# -- clean old link
	unlink($linkname);
	# -- create new link or copy the file
	if($this->{duplicate}) {
		# -- make copy of the file
		if(! copy($srcfile, $linkname)) {
			$reporter->reportError("Cannot copy file '$srcfile' to '$linkname'!");
			return 0;
		}
	}
	else {
		# -- only link the file
		if(! symlink($srcfile, $linkname)) {
			$reporter->reportError("Cannot create link $linkname!");
			return 0;
		}
	}
	
	return 1;
}

return 1;
