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

# Generic task interface
package SMake::Model::Task;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new task object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the task
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the task
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get arguments of the task
#
# The arguments are a hash table with a content which meaning depends on the type
# of the task.
sub getArguments {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stage which the task belongs to
sub getStage {
  SMake::Utils::Abstract::dieAbstract();
}

# Get working path of the task
#
# The path has meaning in the context of the repository
sub getWDPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Set (overwrite) the list of target resources
#
# Usage: setTargets(\@list)
#    list .... list of resources
sub setTargets {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list target resources
#
# Usage: getTargets()
# Returns: \@list
sub getTargets {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of names of source resources
#
# Usage: getSourceNames()
# Returns: \@list
sub getSourceNames {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of source resources
#
# Usage: deleteSources(\@list)
#    list .... list of resource names (strings)
sub deleteSources {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of source resources
#
# Usage: getSources()
# Returns: \@list
sub getSources {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new source timestamp
#
# Usage: createSourceTimestamp($resource)
# Returns: the timestamp
sub createSourceTimestamp {
  SMake::Utils::Abstract::dieAbstract();
}

# Get source timestamp object
#
# Usage: getSourceTimestamp($name)
#    name .... name (relative path) of the timestamp's resource
sub getSourceTimestamp {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of source timestamps
#
# Usage: getSourceTimestamp()
# Returns: \@list
sub getSourceTimestamps {
  SMake::Utils::Abstract::dieAbstract();
}

# Append an external dependency
#
# Usage: appendDependency($dep)
sub appendDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of external dependencies
#
# Returns: \@list
sub getDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a printable representation of the task's key
sub printableKey {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of ids of tasks which this is dependent on
#
# Usage: getDependentTasks($reporter, $subsystem)
#    reporter .... a reporter object
#    subsystem ... logging subsystem
# Returns: \@list of task ids
sub getDependentTasks {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
