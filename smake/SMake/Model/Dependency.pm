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

# An object which describes a dependency of an artifact
package SMake::Model::Dependency;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new dependency object
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Model::Object->new(), $class);
  
  return $this;
}

# Get type of the dependency
sub getDependencyType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a name of the project
sub getDependencyProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Get name of the artifact
sub getDependencyArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
