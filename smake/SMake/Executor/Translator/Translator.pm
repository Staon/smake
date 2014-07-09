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

# Generic command translator interface
package SMake::Executor::Translator::Translator;

use SMake::Utils::Abstract;

# Create new translator record
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Translate command
#
# Usage: translate($context, $task, $command, $wd)
#    context ...... executor context
#    task ......... the task object
#    command ...... logical command tree
#    wd ........... absolute physical path of the task's working directory
# Return:
#    \@commands ... list instruction objects
sub translate {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
