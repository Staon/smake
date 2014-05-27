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

# Generic interface of command builders
package SMake::Executor::Builder::Builder;

use SMake::Executor::Command::Resource;
use SMake::Utils::Abstract;

# Create new command builder
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Build command tree for specified task
#
# Usage: build($context, $task)
#    context ..... executor context
#    task ........ the task
# Returns: \@commands ... list of constructed abstract commands
sub build {
  SMake::Utils::Abstract::dieAbstract();
}

# A helper method - get physical path of a resource
#
# Usage: getResourcePath($context, $resource)
# Returns: the physical path
sub getResourcePath {
  my ($this, $context, $resource) = @_;
  return SMake::Data::Path->fromSystem(
      $context->getRepository()->getPhysicalPath($resource->getPath()))
}

# A helper method - create resource node of a resource
#
# Usage: createResourceNode($context, $resource)
# Returns: the node
sub createResourceNode {
  my ($this, $context, $resource) = @_;
  return SMake::Executor::Command::Resource->new(
      $this->getResourcePath($context, $resource));
}

return 1;
