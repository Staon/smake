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

# Task executor
package SMake::Executor::Task;

use SMake::Executor::Executor;
use SMake::Executor::Instruction::Instruction;
use SMake::Profile::Profile;
use SMake::Profile::Stack;
use SMake::Utils::Utils;

# Create new task executor
#
# Usage: new($context, $taskaddress)
sub new {
  my ($class, $context, $taskaddress) = @_;
  my $this = bless({
    taskaddress => $taskaddress,
  }, $class);

  # -- get model object
  my ($project, $artifact, $stage, $task) = $this->{taskaddress}->getObjects(
      $context, $SMake::Executor::Executor::SUBSYSTEM);
  
  # -- build abstract command tree
  my $builder = $context->getToolChain()->getBuilder();
  my $commands = $builder->build($context, $task);
  
  # -- construct stack of compilation profiles
  my $profstack = SMake::Profile::Stack->new($context->getProfiles());
  my $profobjects = $task->getProfiles();
  foreach my $profobject (@$profobjects) {
    $profstack->appendProfile(
        SMake::Profile::Profile::ressurect($profobject->getDumpString()));
  }
  
  # -- translate command to a shell commands
  my $translator = $context->getToolChain()->getTranslator();
  my $wd = $task->getWDPhysicalPathString();
  my $instructions = [];
  foreach my $command (@$commands) {
    # -- modify command by compilation profiles
    $command = $profstack->modifyCommand($context, $command, $task);
    
    # -- translate the logical command to a sequence of instructions
  	my $instrs = $translator->translate($context, $command, $wd);
    push @$instructions, @$instrs;
  }
  $this->{wdir} = $wd;
  $this->{instructions} = $instructions;
  
  return $this;
}

# Execute the task
#
# Usage: execute($context)
# Returns: false if the task is finished, true if there are other work
sub execute {
  my ($this, $context) = @_;
  
  while($#{$this->{instructions}} >= 0) {
    my $status = $this->{instructions}->[0]->execute(
        $context, $this->{taskaddress}, $this->{wdir});
    if($status eq $SMake::Executor::Instruction::Instruction::WAIT) {
      return 1;
    }
    if($status eq $SMake::Executor::Instruction::Instruction::STOP) {
      $this->{instructions} = [];
    }
    if($status eq $SMake::Executor::Instruction::Instruction::NEXT) {
      shift @{$this->{instructions}};
    }
  }
  
  # -- TODO: report finished task
  return 0;
}

# Get task's ID
sub getTaskID {
  my ($this) = @_;
  return $this->{taskaddress}->getTask();
}

return 1;
