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

#  Resource of a target (generated) file
package SBuild::TargetResource;

use SBuild::FileResource;

@ISA = qw(SBuild::FileResource);

#  Ctor
#
#  Usage: newResource($filename)
sub newResource {
	my $class = $_[0];
	my $this = SBuild::FileResource->newResource($_[1]);
	bless $this, $class;
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
	
	my $filename = $this->getFilename;
	return $profile->getDirEngine->getTargetFile($filename);
}

#  Get absolute path of the file
#
#  Usage: getAbsolute($profile)
sub getAbsolute {
	my $this = $_[0];
	my $profile = $_[1];
	
	my $filename = $this->getFilename;
	return $profile->getDirEngine->getTargetFileAbsolute($filename);
}

#  Get file directory
#
#  Usage: getDirectory($profile)
sub getDirectory {
	my $this = $_[0];
	my $profile = $_[1];
	return $profile->getDirEngine->getTargetPath
}

#  Check if the resource is a source resource
sub isSourceResource {
	return 0;
}

#  Create the same resource with changed filename
#
#  Usage: createFileResource($filename)
sub createFileResource {
	return SBuild::TargetResource->newResource($_[1]);
}

return 1;
