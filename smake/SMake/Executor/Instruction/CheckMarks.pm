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

use SMake::Decider::DeciderList;
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
      $context->getReporter(),
      $SMake::Executor::Executor::SUBSYSTEM,
      $context->getRepository());
  
  # -- force execution of the task
  return $SMake::Executor::Instruction::Instruction::NEXT if($task->isForceRun());

  # -- check timestamps of resources
  my $sources = $task->getSourceTimestamps();
  foreach my $source (@$sources) {
  	# -- no stored mark => compile
    my $stored_mark = $source->getMark();
    return $SMake::Executor::Instruction::Instruction::NEXT if(!$stored_mark);
    
    # -- get file timestamp
    my $curr_mark = $source->computeCurrentMark(
        $context, $SMake::Executor::Executor::SUBSYSTEM);
    if($curr_mark ne $stored_mark) {
      return $SMake::Executor::Instruction::Instruction::NEXT;
    }
  }
  
  # -- nothing changed
  return $SMake::Executor::Instruction::Instruction::STOP;
}

return 1;
