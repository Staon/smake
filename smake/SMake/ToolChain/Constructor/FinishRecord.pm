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

# Finishing record of the generic constructor
package SMake::ToolChain::Constructor::FinishRecord;

use SMake::Utils::Abstract;

sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Do some job while an artifact is closing
#
# Usage: finish($context, $artifact, $constructor)
#    context ...... parser context
#    artifact ..... the artifact
#    constructor .. the generic constructor
sub finish {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
