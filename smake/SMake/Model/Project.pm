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

package SMake::Model::Project;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new project object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Update data of the project
#
# Usage: update($path)
sub update {
  SMake::Utils::Abstract::dieAbstract();
}

# Get name of the project
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get path of the project. The path has a meaning in the context of the repository
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new artifact
#
# Usage: createArtifact($path, $name, $type, \%args)
#    path ..... logical (storage meaning) path of the artifact
#    name ..... name of the artifact
#    type ..... type of the artifact (string, for example "lib", "bin", etc.)
#    args ..... optional artifact arguments
sub createArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get artifact
#
# Usage: getArtifact($name)
# Returns: the artifact or undef
sub getArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of names of artifacts
#
# Usage: getArtifactNames()
# Returns: \@list
sub getArtifactNames {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete specified artifacts
#
# Usage: deleteArtifacts(\@list)
#    list ..... list of names of artifacts to be deleted
sub deleteArtifacts {
  SMake::Utils::Abstract::dieAbstract();
}

# Search for an external resource in the project
#
# Usage: searchResource($restype, $path)
#    restype ..... regular expression of searched resource types
#    path ........ relative path of the searched resource
# Returns: searched resource or undef
sub searchResource {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
