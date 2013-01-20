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

#  Stage runner
#
#  The stage contains a list of tasks
package SBuild::Stage;

use SBuild::Task;

#  Ctor
#
#  Usage: newStage($name)
sub newStage {
	my $class = shift;
	my $this = { 
		name => $_[0],
		tasks => []};
	bless $this, $class;
}

#  Get stage name
sub getName {
	my $this = shift;
	return $this->{name};
}

#  Check if the stage is empty
sub isEmpty {
	my $this = shift;
	return @{$this->{tasks}} == 0;
}

#  Append a task into the stage
#
#  Usage: appendTask($task)
sub appendTask {
	my $this = $_[0];
	my $task = $_[1];
	my $tasks = $this->{tasks};
	$tasks->[@$tasks] = $task;
}

#  Append a list of tasks
#
#  Usage: appendTasks(\@tasks)
sub appendTasks {
	my $this = $_[0];
	my $tasks = $_[1];
	$this->appendTask($_) foreach (@$tasks);
}

#  Get a task
#
#  Usage: getTask($taskname)
sub getTask {
	my $this = $_[0];
	my $taskname = $_[1];
	foreach my $task (@{$this->{tasks}}) {
		return $task if($task->getName eq $taskname);
	}
	return undef;
}

#  Prepare the stage to run
#
#  Usage: initProcessing($profile, $reporter)
sub initProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];

#	my $tasks = $this->{tasks};
#	$_->cleanRunFlag foreach (@$tasks);

	return 1;
}

#  Clean the stage after a run
#
#  Usage: cleanProcessing($profile, $reporter)
sub cleanProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	return 1;
}

#  Run all tasks
#
#  Usage: runStage($profile, $reporter, $project)
#  Return: OK/ERR
sub runStage {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	# -- report entering of the stage
	$reporter->enterStage($this->{name});
	
	# -- run the tasks
	my $tasks = $this->{tasks};
	my $info = 1;
	foreach my $task (@$tasks) {
		$info = $task->runTask($profile, $reporter, $project);
		last if(! $info);
	}
	
	# -- report leaving of the stage
	$reporter->leaveStage($this->{name});
	
	return $info;
}

return 1;
