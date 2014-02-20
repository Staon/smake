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

# Stage executor
package SMake::Executor::Stage;

use SMake::Executor::Executor;
use SMake::Utils::TopOrder;
use SMake::Utils::Utils;

sub getChildren {
  my ($reporter, $repository, $executor, $taskid) = @_;
  
  my ($project, $artifact, $stage) = $executor->getAddress()->getObjects(
      $reporter, $SMake::Executor::Executor::SUBSYSTEM, $repository);
  my $task = $stage->getTask($taskid);
  die "unknown task" if(!defined($task));
  return $task->getDependentTasks($reporter, $SMake::Executor::Executor::SUBSYSTEM);
}

# Create new stage executor
#
# Usage: new($reporter, $repository, $address)
sub new {
  my ($class, $reporter, $repository, $address) = @_;
  my $this = bless({
    address => $address,
  }, $class);
  $this->{toporder} = SMake::Utils::TopOrder->new(
      sub { return $_[0]; },
      sub { return getChildren($reporter, $repository, $this, $_[0]); });

  # -- compute topological order of tasks inside the stage
  my ($project, $artifact, $stage) = $address->getObjects(
      $reporter, $SMake::Executor::Executor::SUBSYSTEM, $repository);
  my $tasks = $stage->getTasks();
  my ($info, $cyclelist) = $this->{toporder}->compute($tasks);
  if(!$info) {
    $reporter->reportf(
        1,
        "critical",
        $SMake::Executor::Exectuor::SUBSYSTEM,
        "a cycle is detected between task dependencies: ");
    foreach my $taskid (@$cyclelist) {
      my $task = $stage->getTask($taskid);
      $reporter->reportf(
        1,
        "critical",
        $SMake::Executor::Exectuor::SUBSYSTEM,
        "    %s.%s",
        $address->printableString(),
        $task->printableKey());
    }
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SMake::Executor::Exectuor::SUBSYSTEM,
        "stopped, it's not possible to continue in work");
  }
  
  return $this;
}

# Execute the stage
#
# Usage: execute($reporter, $repository)
# Returns: false if the stage is finished, true if there are other work
sub execute {
  my ($this, $reporter, $repository) = @_;

  my $tasks = $this->{toporder}->getLeaves();
  return 0 if(!defined($tasks));  # -- nothing to do anymore
  
  foreach my $taskid (@$tasks) {
  	print "finish task " . $this->{address}->printableString() . "." . $taskid . "\n";
  	$this->{toporder}->finishObject($taskid);
  	
    # -- TODO: schedule the tasks
  }
  
  return 1;
}

# Get the stage address
sub getAddress {
  my ($this) = @_;
  return $this->{address};
}

return 1;
