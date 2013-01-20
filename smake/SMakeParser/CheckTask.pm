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

#  Test check task
#
#  This task runs generated test runner. When the test fails
#  the task fails too.
package SMakeParser::CheckTask;

use SBuild::Task;

@ISA = qw(SBuild::Task);

#  Ctor
#
#  Usage: newTask($name, $resource, $testrunner)
sub newTask {
	my $class = shift;
	my $this = SBuild::Task->newTask($_[0], $_[1]);
	$this->{testrunner} = $_[2];
	bless $this, $class;
}

#  Run the compilation
#    Usage: processTask(profile, reporter)
#    Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];

	# Compose the command
	my $command = "./" . $this->{testrunner}->getFullname($profile);
	
	# Report the command
	$reporter->taskCommand($this->getName, $command);
	# Run the command
	my $runner = $profile->getRunner;
	my $info = $runner->runCommandConsole($command);
	my $result;
	if(! $info) {
		$result = "The test fell down!";
	}
	else {
		$result = "";
	}
	# Report the result
	$reporter->taskResult($this->getName, $info, $result);
	
	return $info;
}

return 1;
