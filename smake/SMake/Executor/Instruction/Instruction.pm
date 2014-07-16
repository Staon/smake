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

# Generic instruction - end commands after translation from logical
# command trees.
package SMake::Executor::Instruction::Instruction;

use SMake::Utils::Abstract;
use SMake::Utils::Chdir;

$WAIT = "wait";
$NEXT = "next";
$STOP = "stop";
$ERROR = "error";

# Create new instruction
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Execute the instruction
#
# Usage: execute($context, $taskaddress, $wdir)
#    context ...... executor context
#    taskaddress .. address of current task
#    wdir ......... task's working directory
# Returns:
#    one of the strings:
#        SMake::Executor::Instruction::Instruction::WAIT ("wait")
#             wait for command finish
#        SMake::Executor::Instruction::Instruction::NEXT ("next")
#             the command finished and next instruction should be executed
#        SMake::Executor::Instruction::Instruction::WAIT ("stop")
#             the command finished and the task should be finished too
sub execute {
  SMake::Utils::Abstract::dieAbstract();
}

# Helper method - store current working directory and set new
#
# Usage: pushWD($context, $subsystem, $wd)
# Returns: a dirkeeper
sub pushWD {
  my ($this, $context, $subsystem, $wd) = @_;
  
  my $dirkeeper = SMake::Utils::Chdir->new();
  if(defined($wd)) {
    $dirkeeper->pushDir(
        $wd->systemAbsolute(),
        $context->getReporter(),
        $subsystem);
  }
  return $dirkeeper;
}

# Helper method - get back the working directory
#
# Usage: pushWD($context, $subsystem, $wd, $dirkeeper)
sub popWD {
  my ($this, $context, $subsystem, $wd, $dirkeeper) = @_;

  if(defined($wd)) {
    $dirkeeper->popDir(
        $context->getReporter(),
        $subsystem);
  }
}

return 1;
