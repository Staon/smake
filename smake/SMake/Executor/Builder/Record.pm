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

# Composing record - a record which describes part of composed logical
# command.
package SMake::Executor::Builder::Record;

use SMake::Executor::Command::Resource;
use SMake::Utils::Abstract;

# Create new record
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Compose the command
#
# Usage: compose($context, $task, $command)
#    context ....... executor context
#    task .......... command's task
#    command ....... root set container of the composed command
sub compose {
  SMake::Utils::Abstract::dieAbstract();
}

# A helper method - get physical path of a resource
#
# Usage: getResourcePath($context, $resource)
# Returns: the physical path
sub getResourcePath {
  my ($this, $context, $resource) = @_;
  return $resource->getPhysicalPath();
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
