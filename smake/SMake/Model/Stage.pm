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

use SMake::Data::Address;
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

# Create new task
#
# Usage: createTask($name, $type, $wd, \%arguments)
#    name ....... name of the task
#    type ....... type of the task
#    wd ......... task's working directory (a path object in repository meaning)
#    arguments .. task's generic arguments
# Returns: new task
sub createTask {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a task
#
# Usage: getTask($name)
# Returns: the task or undef
sub getTask {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of names of tasks which belongs the stage
#
# Usage: getTaskNames()
# Returns: \@task_list list of task names
sub getTaskNames {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of tasks
#
# Usage: deleteTasks(\@list)
#    list .... list of task names
sub deleteTasks {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of dependencies of the stage
#
# Usage: getDependencies($reporter, $subsystem)
#    reporter ...... a reporter object
#    subsystem ..... id of the logging subsystem
# Returns: \@list .. list of dependencies as a list of stage addresses
sub getDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Create address of this stage
sub getAddress {
  my ($this) = @_;
  return SMake::Data::Address->new(
      $this->getProject()->getName(),
      $this->getArtifact()->getName(),
      $this->getName());
}

return 1;
