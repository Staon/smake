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

# Generic stage object
package SMake::Model::Stage;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new stage object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the stage
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get artifact which the stage belongs to
sub getArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get project which the state belongs to
sub getProject {
  my ($this) = @_;
  return $this->getArtifact()->getProject();
}

return 1;
