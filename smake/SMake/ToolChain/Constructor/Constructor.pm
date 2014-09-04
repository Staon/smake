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

# Generic artifact constructor
package SMake::ToolChain::Constructor::Constructor;

use SMake::Utils::Abstract;

$SUBSYSTEM = "constructor";

# Create new constructor object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Construct artifact
#
# Usage: constructArtifact($context, $artifact)
#    context .... parser context
#    artifact ... the artifact object
sub constructArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Prepare constructor's main resources
#
# Usage: createMainResources($context, $artifact)
#    context .... parser context
#    artifact ... the artifact object
sub createMainResources {
  SMake::Utils::Abstract::dieAbstract();
}

# Resolve queue of resources in area of the artifact
#
# Usage: resolveResources($context, $artifact, \@list)
#    context ..... parser context
#    artifact .... the artifact object
#    list ........ list of resources
sub resolveResources {
  SMake::Utils::Abstract::dieAbstract();
}

# Resolve list of dependencies
#
# Usage: resolveDependencies($context, $artifact, \@list)
#    context ..... parser context
#    artifact .... the artifact object
#    list ........ list of the dependencies
sub resolveDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Finish construction of an artifact
#
# Usage: finishArtifact($context, $artifact)
#    context ..... parser context
#    artifact .... the artifact object
sub finishArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
