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

package SBuild::Task;

use SBuild::ProfileList;

# Ctor
#  Usage: newTask($name, $resource);
sub newTask {
	my $class = $_[0];
	my $this = { 
		name => $_[1]
	};
	if(defined($_[2])) {
		$this->{profile} = $_[2]->getProfileList;
	}
	else {
		$this->{profile} = SBuild::ProfileList->newProfileList;
	}
	bless $this, $class;
}

# Get task name
sub getName {
	my $this = shift;
	return $this->{name};
}

#  Set task's stage
#
#  Usage: setStage($stage)
sub setStage {
	my $this = $_[0];
	my $stage = $_[1];
	$this->{stage} = $stage;
}

#  Get task's stage
sub getStage {
	my $this = $_[0];
	return $this->{stage};
}

#  Set task mark
sub setTaskMark {
	my $this = $_[0];
	my $mark = $_[1];
	$this->{task_mark} = $mark;
}

# Run the task
#  Usage: runTask($profile, $reporter, $project)
#  Returns: False when the task fails
sub runTask {
	my $this = shift;
	my $profile = $_[0];
	my $reporter = $_[1];
	my $project = $_[2];
	
	# Report entering of the task
	$reporter->enterTask($this->getName);
	# Push the profile list into the profile stack
	$profile->getProfileStack->pushList($this->{profile});
	# Run the task
	my $retval = $this->initTask(@_);
	if($retval && $this->shallBeRun(@_)) {
		$retval = $this->processTask(@_);
		$project->activateTaskMark($this->{task_mark}) if(defined($this->{task_mark}));
		$retval = $this->cleanTask(@_, $retval) && $retval;
	}
	# Pop the profile list
	$profile->getProfileStack->popList;
	# Report leaving of the task
	$reporter->leaveTask($this->getName);
	
	return $retval;
}

# Default empty running method
#   Usage: processTask(profile, reporter, $project)
#   Return: False when the task fails
sub processTask {
	return 1;
}

#  Initialize task work
#
#  Usage: initTask($profile, $reporter, $project)
sub initTask {
	return 1;
}

#  Clean task work
#
#  Usage: cleanTask($profile, $reporter, $project, $status)
sub cleanTask {
	return 1;
}

#  Decide if the task should be run
#
#  Usage: shallBeRun($profile, $reporter, $project)
#  Return: True when the project shall be run
sub shallBeRun {
	return 1;
}

#  Convert a list of resources into a list of full filenames
#
#  Usage: convertToFileList($profile, \@reslist): \@filelist
sub convertToFileList {
	my $this = $_[0];
	my $profile = $_[1];
	my $reslist = $_[2];
	
	my @filelist = ();
	foreach my $resource (@$reslist) {
		push @filelist, $resource->getFullname($profile);
	}
	return \@filelist;
}

#  Convert a list of resources into a list of full directories
#
#  Usage: convertToDirList($profile, \@reslist): \@dirlist
sub convertToDirList {
	my $this = $_[0];
	my $profile = $_[1];
	my $reslist = $_[2];
	
	my @dirlist = ();
	foreach my $resource (@$reslist) {
		push @dirlist, $resource->getFullDirectory($profile);
	}
	return \@dirlist;
}

return 1;
