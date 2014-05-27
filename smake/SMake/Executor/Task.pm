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
use SMake::Utils::Utils;

# Create new task executor
#
# Usage: new($context, $stageid, $taskid)
sub new {
  my ($class, $context, $stageid, $taskid) = @_;
  my $this = bless({
    stageid => $stageid,
    taskid => $taskid,
  }, $class);

  # -- get model object
  my ($project, $artifact, $stage) = $this->{stageid}->getObjects(
      $context->getReporter(),
      $SMake::Executor::Executor::SUBSYSTEM,
      $context->getRepository());
  my $task = $stage->getTask($this->{taskid});
  if(!defined($task)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "there is something wrong, the task %s.%s is not known!",
        $this->{stageid}->printableString(),
        $this->{taskid});
  }
  
  # -- TODO: check resource modifications
  
  # -- build abstract command tree
  my $builder = $context->getToolChain()->getBuilder();
  my $commands = $builder->build($context, $task);
  
  # -- translate command to a shell commands
  my $translator = $context->getToolChain()->getTranslator();
  my $wd = SMake::Data::Path->fromSystem(
      $context->getRepository()->getPhysicalPath($task->getWDPath()));
  my $shellcmds = [];
  foreach my $command (@$commands) {
  	my $scmds = $translator->translate($context, $command, $wd);
    push @$shellcmds, @$scmds;
  }
  $this->{commands} = $shellcmds;
  
  return $this;
}

# Execute the task
#
# Usage: execute($context)
# Returns: false if the task is finished, true if there are other work
sub execute {
  my ($this, $context) = @_;
  
  if($#{$this->{commands}} >= 0) {
    my $command = shift(@{$this->{commands}});
    print "Execute command: $command\n";
    return 1;  	
  }
  else {
    print "finish task " . $this->{stageid}->printableString() . "." . $this->{taskid} . "\n";
    return 0;
  }
}

# Get task's ID
sub getTaskID {
  my ($this) = @_;
  return $this->{taskid};
}

return 1;
