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

#  One compilation project
package SBuild::Project;

use SBuild::ProfileList;
use SBuild::Chdir;
use SBuild::InstallLogger;

#  Ctor
#
#  Usage: newProject($name, \%args, $anonymous, $path, $shared_profile) 
sub newProject {
	my $class = $_[0];
	my $this = {
		name => $_[1],
		args => $_[2],
		anonymous =>$_[3],
		stages => {},
		repository_profile => SBuild::ProfileList->newProfileList,
		profile => SBuild::ProfileList->newProfileList,
		path => $_[4],
		okflag => 1,
		shared_profile => $_[5],
		task_marks => {}
	};
	bless $this, $class;
}

#  Get project name
sub getName {
	my $this = shift;
	return $this->{name};
}

#  Set project name
sub setName {
	my $this = shift;
	$this->{name} = $_[0];
}

#  Get a project argument
#
#  Usage: getArgument($argname)
sub getArgument {
	my $this = $_[0];
	my $argname = $_[1];
	return $this->{args}->{$argname};
}

#  Get version string
sub getVersion {
	my $this = $_[0];
	return $this->getArgument('version');
}

#  Get project location
sub getPath {
	my $this = shift;
	return $this->{path};
}

#  Is the project anonymous?
sub isAnonymous {
	my $this = shift;
	return $this->{anonymous};
}

#  Prepare the project to be run
#
#  Usage: initProcessing($profile, $reporter)
sub initProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	# -- clean the OK flag and task marks
	$this->{okflag} = 1;
	$this->{task_marks} = {};
	# -- prepare all stages
	my $retval = 1;
	$retval = $_->initProcessing($profile, $reporter) && $retval
					foreach (values(%{$this->{stages}}));
	return $retval;
}

#  Clean the project after a run
#
#  Usage: cleanProcessing($profile, $reporter)
sub cleanProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	# -- store and clean the installation log
	$this->storeInstallLog($profile, $reporter);
	delete $this->{install_logger}; 
	# -- clean all stages
	my $retval = 1;
	$retval = $_->cleanProcessing($profile, $reporter) && $retval
					foreach (values(%{$this->{stages}}));
	return $retval;
}

#  Check if a stage is empty
#
#  Usage: isStageEmpty($stage)
sub isStageEmpty {
	my $this = $_[0];
	my $stage = $_[1];
	my $s = $this->{stages}->{$stage};
	return $s->isEmpty if(defined($s));
	return 1;
}

#  Add a new compilation profile
#
#  Usage: appendProfile($profile)
sub appendProfile {
	my $this = $_[0];
	$this->{profile}->appendProfile($_[1]);
}

#  Add a new compilation profile which is derived from configuration of
#  the repository
#
#  Usage: appendRepositoryProfile($profile)
sub appendRepositoryProfile {
	my $this = $_[0];
	$this->{repository_profile}->appendProfile($_[1]);
}

#  Push all profile lists of the project
#
#  Usage: pushProfileLists($profile_stack)
sub pushProfileLists {
	my $this = $_[0];
	my $stack = $_[1];
	
	$stack->pushList($this->{repository_profile});
	if(defined($this->{shared_profile})) {
		$stack->pushList($this->{shared_profile});
	}
	$stack->pushList($this->{profile});
}

#  Pop all profile lists of the project
#
#  Usage: popProfileLists($profile_stack)
sub popProfileLists {
	my $this = $_[0];
	my $stack = $_[1];
	
	$stack->popList;
	if(defined($this->{shared_profile})) {
		$stack->popList;
	}
	$stack->popList;
}

#  Append a new compilation unit
#
#  Usage: appendStage($stage)
sub appendStage {
	my $this = $_[0];
	my $stage = $_[1];
	$this->{stages}->{$stage->getName} = $stage;
}

#  Activate a task mark
#
#  Usage: activateTaskMark($mark)
sub activateTaskMark {
	my $this = $_[0];
	my $mark = $_[1];
	$this->{task_marks}->{$mark} = 1;
}

#  Check if a task mark is active
#
#  Usage: isTaskMarkActive($mark);
sub isTaskMarkActive {
	my $this = $_[0];
	my $mark = $_[1];
	return defined($this->{task_marks}->{$mark});
}

#  Run the project
#
#  Usage: runProject($stage, $profile, $reporter)
#  Return: OK or ERR
sub runProject {
	my $this = $_[0];
	my $stage = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	
	if($this->{okflag}) {
		# Find the stage. When the stage is empty do nothing.
		my $s = $this->{stages}->{$stage};
		return 1 if(! $s or $s->isEmpty);
		
		# -- report the project
		$reporter->enterProject($this->getName, $this->getPath);
		
		# -- change current directory
		my $chdir = SBuild::Chdir->newChdir;
		if(! $chdir->pushDir($this->getPath, $reporter)) {
			$this->{okflag} = 0;
			# -- report the project
			$reporter->leaveProject($this->getName, $this->getPath);
			return 0;
		}

		# -- set current project
		$profile->setCurrentProject($this);
		
		# -- push my compilation profiles
		$this->pushProfileLists($profile->getProfileStack);
	
		# -- run the stage
		my $info = 1;
		$info = $s->runStage($profile, $reporter, $this) if(defined($s));
		if(! $info) {
			$this->{okflag} = 0;
		}
	
		# -- pop my compilation profiles
		$this->popProfileLists($profile->getProfileStack);
		
		# -- clean current project
		$profile->cleanCurrentProject;
		
		# -- turn back the current working directory
		if(! $chdir->popDir($reporter)) {
			$info = 0;
			$this->{okflag} = 0;
		}

		# -- report the project
		$reporter->leaveProject($this->getName, $this->getPath);
		
		return $info;
	}

	$reporter->brokenProject($this->getName, $this->getPath, $stage);
	return 0;
}

#  Get the install logger
#
#  Usage: getInstallLogger($profile)
sub getInstallLogger {
	my $this = $_[0];
	my $profile = $_[1];
	
	my $logger = $profile->getInstallLogger($this->getPath);
	if(! defined($logger)) {
		$logger = SBuild::InstallLogger->newLogger($profile, $this->getPath);
		$profile->setInstallLogger($this->getPath, $logger);
	}
	return $logger;
}

#  Store the installation log
#
#  Usage: storeInstallLog($profile, $reporter)
sub storeInstallLog {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	my $logger = $profile->getInstallLogger($this->getPath);
	if(defined($logger)) {
		$logger->storeLog($profile, $reporter);
		$profile->cleanInstallLogger($this->getPath);
	}
}

#  Print a text which describes the project to a standard output
sub printItself {
	my $this = $_[0];
	
	if(! $this->isAnonymous) {
		print $this->getName;
	}
	else {
		print "Anonymous project";
	}
	print  " - " . $this->getPath . "\n";
}

return 1;
