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

# Generic storage of project data
package SMake::Storage::Storage;

use SMake::Utils::Abstract;

# Create new storage object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Destroy the storage
#
# Usage: destroyStorage($repository);
sub destroyStorage {
  SMake::Utils::Abstract::dieAbstract();
}

# Open storage transaction
#
# Usage: openTransaction($repository)
# Exception: it can die when an error occurs
sub openTransaction {
  SMake::Utils::Abstract::dieAbstract();
}

# Commit currently opened transaction
#
# Usage: commitTransaction($repository)
# Exception: it dies if an error occurs
sub commitTransaction {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new project object
#
# Usage: createProject($repository, $name, $path)
#    repository ... owning repository
#    name ......... name of the project
#    path ......... logical path of the project
sub createProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Get project object
#
# Usage: getProject($repository, $name)
#    repository ... owning repository
#    name ......... name of the project
sub getProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Search for a public resource
#
# Usage: searchPublicResource($repository, $resource)
#    repository ... owning repository
#    resource ..... resource key tuple
# Returns: \@list
#    list ......... list of project key tuples or undef
sub searchPublicResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Check if the source and the product trees are separated. If this method is
# true target (product) directories are created and cleaned with the product
# resources too.
sub isBuildTreeSeparated {
  SMake::Utils::Abstract::dieAbstract();
}

# Get physical (filesystem) location
#
# Usage: getPhysicalLocation($restype, $path)
#    restype ..... type of the resource
#    path ..... a path object in the storage meaning
# Returns: a path object with absolute filesystem path
sub getPhysicalLocation {
  SMake::Utils::Abstract::dieAbstract();
}

# Convert a physical location to repository path
#
# Usage: getRepositoryLocation($restype, $path)
#    restype ..... type of the resource
#    path ........ the physical path
# Returns: a path object with repository location
sub getRepositoryLocation {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
