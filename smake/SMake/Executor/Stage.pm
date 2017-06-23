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

use SMake::Data::TaskAddress;
use SMake::Executor::Executor;
use SMake::Executor::Task;
use SMake::Utils::TopOrder;
use SMake::Utils::Utils;

sub getChildren {
  my ($context, $executor, $taskid) = @_;
  
  my ($project, $artifact, $stage) = $executor->getAddress()->getObjects(
      $context, $SMake::Executor::Executor::SUBSYSTEM);
  my $task = $stage->getTask($taskid);
  die "unknown task" if(!defined($task));
  return $task->getDependentTasks(
      $context, $SMake::Executor::Executor::SUBSYSTEM);
}

# Create new stage executor
#
# Usage: new($context, $address)
sub new {
  my ($class, $context, $address) = @_;
  my $this = bless({
    address => $address,
    tasklist => [],
    broken => 0,
  }, $class);
  $this->{toporder} = SMake::Utils::TopOrder->new(
      sub { return $_[0]; },
      sub { return getChildren($context, $this, $_[0]); });

  my ($project, $artifact, $stage) = $address->getObjects(
      $context, $SMake::Executor::Executor::SUBSYSTEM);
  if($stage->isBroken()) {
    $context->getReporter()->reportf(
        1,
        "error",
        $SMake::Executor::Executor::SUBSYSTEM,
        "the stage '%s' is broken!",
        $address->printableString());
  }
  else {
    # -- compute topological order of tasks inside the stage
    my $tasks = $stage->getTaskNames();
    my ($info, $cyclelist) = $this->{toporder}->compute($tasks);
    if(!$info) {
      $context->getReporter()->reportf(
          1,
          "critical",
          $SMake::Executor::Executor::SUBSYSTEM,
          "a cycle is detected between task dependencies: ");
      foreach my $taskid (@$cyclelist) {
        my $task = $stage->getTask($taskid);
        $context->getReporter()->reportf(
          1,
          "critical",
          $SMake::Executor::Executor::SUBSYSTEM,
          "    %s.%s",
          $address->printableString(),
          $task->printableKey());
      }
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Executor::Executor::SUBSYSTEM,
          "stopped, it's not possible to continue in work");
    }
  }
  
  return $this;
}

sub appendTaskExecutor {
  my ($this, $context) = @_;
  
  my $some_new = 0;
  my $tasks = $this->{toporder}->getLeaves();
  foreach my $task (@$tasks) {
    my $taskaddr = SMake::Data::TaskAddress->new($this->{address}, $task);
    my $executor = SMake::Executor::Task->new($context, $taskaddr);
    push @{$this->{tasklist}}, $executor;
    $some_new = 1;
    $context->getReporter()->reportf(
        2,
        "info",
        $SMake::Executor::Executor::SUBSYSTEM,
        "enter task %s",
        $taskaddr->printableString());
  }
  return $some_new;
}

# Execute the stage
#
# Usage: execute($context)
# Returns: ($running, $errflag)
#     running ..... false if the stage is finished, true if there are other work
#     errflag ..... true when any of the tasks finished with an error
sub execute {
  my ($this, $context) = @_;

  $this->appendTaskExecutor($context);
  while(@{$this->{tasklist}}) {
    my $newlist = [];
    foreach my $task (@{$this->{tasklist}}) {
      my ($running, $errflag) = $task->execute($context);
      if($running) {
        push @$newlist, $task;
      }
      else {
        $this->{toporder}->finishObject($task->getTaskID());
        my $taskaddr = SMake::Data::TaskAddress->new(
            $this->{address}, $task->getTaskID());
        $context->getReporter()->reportf(
            3,
            "info",
            $SMake::Executor::Executor::SUBSYSTEM,
            "leave task %s",
            $taskaddr->printableString());
        
        # -- set broken stage
        if($errflag) {
          $this->{broken} = 1;
          
          # -- fill broken flag into the model data
          my ($project, $artifact, $stage) = $this->getAddress()->getObjects(
              $context, $SMake::Executor::Executor::SUBSYSTEM);
          $stage->breakStage();
          
          # -- stop running, if the force mode is not active
          if(!$context->forceRun()) {
            return (0, 1);
          }
        }
      }
    }
    $this->{tasklist} = $newlist;
    last if(!$this->appendTaskExecutor($context));
  }
  
  if(@{$this->{tasklist}}) {
    return (1, $this->{broken});  # -- still some work
  }
  else {
    return (0, $this->{broken});  # -- finished stage
  }
}

# Get the stage address
sub getAddress {
  my ($this) = @_;
  return $this->{address};
}

return 1;
