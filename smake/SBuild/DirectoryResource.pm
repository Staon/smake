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

#  Resource which describes a directory
package SBuild::DirectoryResource;

use SBuild::Resource;

@ISA = qw(SBuild::Resource);

#  Ctor
#
#  Usage: newResource($dirname)
sub newResource {
	my $class = $_[0];
	my $this = SBuild::Resource->newResource($_[1]);
	bless $this, $class;
}

#  Get directory name
sub getDirectory {
	my $this = $_[0];
	return $this->getID;
}

#  Are directory paths the same?
sub isEqual {
	my $this = $_[0];
	my $operand = $_[1];
	return $this->getID eq $operand->getID;
}

#  Get object of full directory path
#
#  Usage: getFullDirectoryObject($profile)
sub getFullDirectoryObject {
	die "Pure virtual method: DirectoryResource::getFullDirectoryObject";
}

#  Get full directory object absolute
#
#  Usage: getFullDirectoryObjectAbsolute($profile);
sub getFullDirectoryObjectAbsolute {
	die "Pure virtual method: DirectoryResource::getFullDirectoryObjectAbsolute";
}

#  Get full directory path
#
#  Usage: getFullDirectory($profile)
sub getFullDirectory {
	my $this = $_[0];
	my $profile = $_[1];
	return $this->getFullDirectoryObject($profile)->getPath;
}

#  Get full directory absolute path
#
#  Usage: getFullDirectoryAbsolute($profile)
sub getFullDirectoryAbsolute {
	my $this = $_[0];
	my $profile = $_[1];
	return $this->getFullDirectoryObjectAbsolute($profile)->getPath;
}

return 1;
