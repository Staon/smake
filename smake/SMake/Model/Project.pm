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

use SMake::Utils::Abstract;

# Create new project object
#
# Usage: new($repository)
sub new {
  my ($class, $repository) = @_;
  return bless({ repository => $repository }, $class);
}

# Get storage which the project is associated with
#
# Usage: getRepository()
sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

# Get name of the project
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get version identifier of the project
sub getVersion {
  SMake::Utils::Abstract::dieAbstract();
}

# Get identifier of the variant
sub getVariant {
  SMake::Utils::Abstract::dieAbstract();
}

# Get path of the project. The path has a meaning in the context of owning repository
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get canonical path of the project. The path has meaning at the filesystem.
sub getPhysicalPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Add new description object or overwrite an old object
#
# Usage: addDescription($description)
#    description ... description object
sub attachDescription {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new artifact
#
# Usage: createArtifact($name, $type, \%args)
#    name ..... name of the artifact
#    type ..... type of the artifact (string, for example "lib", "bin", etc.)
#    args ..... optional artifact arguments
sub createArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
