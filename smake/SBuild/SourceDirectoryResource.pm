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

#  Source directory resource
package SBuild::SourceDirectoryResource;

use SBuild::DirectoryResource;

@ISA = qw(SBuild::DirectoryResource);

use SBuild::Directory;
use SBuild::DirectoryRelative;

#  Ctor
#
#  Usage: newResource($dirname)
sub newResource {
	my $class = $_[0];
	my $this = SBuild::DirectoryResource->newResource($_[1]);
	bless $this, $class;
}

#  Get full directory path
#
#  Usage: getFullDirectoryObject($profile)
sub getFullDirectoryObject {
	my $this = $_[0];
	my $profile = $_[1];
	
	my $dir = $profile->getDirEngine->getSourceDirectory;
	return $dir->appendPath(SBuild::DirectoryRelative->newDirectory($this->getDirectory));
}

#  Get full directory object absolute
#
#  Usage: getFullDirectoryObjectAbsolute($profile);
sub getFullDirectoryObjectAbsolute {
	my $this = $_[0];
	my $profile = $_[1];
	
	my $dir = $profile->getDirEngine->getSource;
	return $dir->appendPath(SBuild::DirectoryRelative->newDirectory($this->getDirectory));
}

return 1;
