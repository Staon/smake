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

# Generic resource object
package SMake::Model::Resource;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new resource
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the resource
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the resource
#
# For example type can be "file" for physical file, "install" for a resource
# which is created in the installation are etc.
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get logical path of the resource
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get logical relative path based on the artifact
sub getRelativePath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get task which is a creator of the resource
#
# Returns: the tast or undef, if the resource is an external resource
sub getTask {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stage which the resource is created in
sub getStage {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
