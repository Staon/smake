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
      $context, $SMake::Executor::Executor::SUBSYSTEM);

  # -- update resource timestamps
  my $stamps = $task->getSourceTimestamps();
  push @$stamps, @{$task->getTargetTimestamps()};
  foreach my $stamp (@$stamps) {
    my $curr_mark = $stamp->computeCurrentMark(
        $context, $SMake::Executor::Executor::SUBSYSTEM);
    if(!defined($curr_mark)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Executor::Executor::SUBSYSTEM,
          "product timestamp cannot be computed for resource '%s@%s'!",
          $stamp->getType(),
          $stamp->getName()->asString());
    }
    $stamp->updateMark($curr_mark);
  }

  # -- update timestamps of the dependencies
  my $deps = $task->getDependencies();
  foreach my $dep (@$deps) {
    my $curr_mark = $dep->computeCurrentMark(
        $context, $SMake::Executor::Executor::SUBSYSTEM);
    if(!defined($curr_mark)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Executor::Executor::SUBSYSTEM,
          "timestamp cannot be computed for dependency '%s'!",
          $dep->getKey());
    }
    $dep->updateMark($curr_mark);
  }

  return $SMake::Executor::Instruction::Instruction::NEXT;
}

return 1;
