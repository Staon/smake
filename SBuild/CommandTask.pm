# Copyright (C) 2013 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is free software: you can redistribute it and/or modify
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

#  Generic command task
#
#  This task runs a command through a runner set in the profile.
#
#  Actually the task supports a sequence of commands. Firstly, the task
#  asks child to get count of commands. Then in a cycle the task asks
#  of the commands and runs them.
package SBuild::CommandTask;

use SBuild::Task;
use SBuild::Runner;

@ISA = qw(SBuild::Task);

#  Ctor
#
#    Usage: newTask($name, $resource)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	bless $this, $class;
}

#  Run the compilation
#
#  Usage: processTask(profile, reporter, $project)
#  Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $cmdcount = $this->getCommandCount($profile, $reporter, $project);
	for(my $i = 0; $i < $cmdcount; ++ $i) {
		# Get task command
		my $command = $this->getCommand($profile, $reporter, $project, $i);
		return 0 if(! defined($command));
		# Check if the command should be run with as another user
		my $sudouser = $profile->getProfileStack->getOptions("SUDO", $profile, $reporter);
		if($sudouser ne "") {
			$command = "sudo -u $sudouser $command";
		}
		# Report the command
		$reporter->taskCommand($this->getName, $command);
		# Run the command
		my $runner = $profile->getRunner;
		(my $info, my $result) = $runner->runCommand($command);
		# Report the result
		$reporter->taskResult($this->getName, $info, $result);
		return 0 if(! $info);
	}
	return 1;
}

#  Get count of commands
#
#  Usage: getCommandCount($profile, $reporter, $project)
#  Return: Count of commands. The default value is 1.
sub getCommandCount {
	return 1;	
}

#  Get task command
#  This is a pure virtual method!
#
#  Usage: getCommand($profile, $reporter, $project, $index)
#  Return: Command string
#
#  The $index argument is an index of asked command in the range <0, getCommandCount).
sub getCommand {
	die("Pure virtual method CommandTask::getCommand cannot be called.");
}

return 1;
