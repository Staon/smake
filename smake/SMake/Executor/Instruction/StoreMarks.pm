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

# Store current timestamp marks of all source resources
package SMake::Executor::Instruction::StoreMarks;

use SMake::Executor::Instruction::Instruction;

@ISA = qw(SMake::Executor::Instruction::Instruction);

use SMake::Decider::DeciderList;
use SMake::Executor::Executor;

# Create new instruction
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

  # -- update timestamps
  my $sources = $task->getSourceTimestamps();
  foreach my $source (@$sources) {
    my $curr_mark = $source->computeCurrentMark(
        $context, $SMake::Executor::Executor::SUBSYSTEM);
    $source->updateMark($curr_mark);
  }
  
  return $SMake::Executor::Instruction::Instruction::NEXT;
}

return 1;
