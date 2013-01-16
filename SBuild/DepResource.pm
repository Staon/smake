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

#  Resource which describe a dependency file
package SBuild::DepResource;

use SBuild::FileResource;

@ISA = qw(SBuild::FileResource);

use SBuild::Directory;
use SBuild::DirectoryRelative;
use SBuild::DirectoryEngine;
use SBuild::TargetDirectoryResource;

#  Ctor
#
#  Usage: newResource($filename)
sub newResource {
	my $class = $_[0];
	my $this = SBuild::FileResource->newResource($_[1]);
	bless $this, $class;
}

#  Get resource of the dependency directory
sub getDirectoryResource {
	return SBuild::TargetDirectoryResource->newResource(".deps");	
}

#  Get full filename (with path and extension)
#
#  The full name is computed based on a current directory (see the directory
#  engine).
#
#  Usage: getFullname($profile)
sub getFullname {
	my $this = $_[0];
	my $profile = $_[1];
	
	my $dir = $this->getDirectoryResource->getFullDirectoryObject($profile);
	return $dir->appendFile($this->getFilename);
}

#  Get absolute path of the file
#
#  Usage: getAbsolute($profile)
sub getAbsolute {
	my $this = $_[0];
	my $profile = $_[1];

	my $dir = $this->getDirectoryResource->getFullDirectoryObjectAbsolute($profile);
	return $dir->appendFile($this->getFilename);	
}

#  Get file directory
#
#  Usage: getDirectory($profile)
sub getDirectory {
	my $this = $_[0];
	my $profile = $_[1];

	return $this->getDirectoryResource->getFullDirectoryObject($profile)->getPath; 	
}

#  Check if the resource is a source resource
sub isSourceResource {
	return 0;
}

#  Create the same resource with changed filename
#
#  Usage: createFileResource($filename)
sub createFileResource {
	return SBuild::SourceResource->newResource($_[1]);
}

#  Get resource of the dependency directory
return 1;
