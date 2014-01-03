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

return 1;
