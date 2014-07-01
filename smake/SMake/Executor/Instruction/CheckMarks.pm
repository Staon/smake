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

# Check source marks and stop task if nothing has changed
package SMake::Executor::Instruction::CheckMarks;

use SMake::Executor::Instruction::Instruction;

@ISA = qw(SMake::Executor::Instruction::Instruction);

use SMake::Executor::Executor;

# Create new check mark instruction
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Executor::Instruction::Instruction->new(), $class);
}

sub execute {
  my ($this, $context, $taskaddress, $wdir) = @_;

  # -- get model objects
  my ($project, $artifact, $stage, $task) = $taskaddress->getObjects(
      $context, $SMake::Executor::Executor::SUBSYSTEM);
  
  # -- force execution of the task
  return $SMake::Executor::Instruction::Instruction::NEXT if($task->isForceRun());

  # -- check timestamps of the resources
  my $stamps = $task->getSourceTimestamps();
  push @$stamps, @{$task->getTargetTimestamps()};
  foreach my $stamp (@$stamps) {
  	# -- no stored mark => compile
    my $stored_mark = $stamp->getMark();
    return $SMake::Executor::Instruction::Instruction::NEXT if(!$stored_mark);
    
    # -- get file timestamp
    my $curr_mark = $stamp->computeCurrentMark(
        $context, $SMake::Executor::Executor::SUBSYSTEM);
    if(!defined($curr_mark) || $curr_mark ne $stored_mark) {
      return $SMake::Executor::Instruction::Instruction::NEXT;
    }
  }
  
  # -- nothing changed
  return $SMake::Executor::Instruction::Instruction::STOP;
}

return 1;
