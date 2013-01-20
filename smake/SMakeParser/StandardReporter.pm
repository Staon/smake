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

#  Standard reporter
package SMakeParser::StandardReporter;

use SBuild::Reporter;

@ISA = qw(SBuild::Reporter);

use Term::Cap;

#  Ctor
#
#  Usage newReporter($verbosity)
sub newReporter {
	my $class = $_[0];
	my $this = SBuild::Reporter->newReporter;
	$this->{verbosity} = defined($_[1])?$_[1]:3;
	
	# -- initialize the termcap object
	my $terminal = Term::Cap->Tgetent({ TERM => undef, OSPEED => 9600 });
	if(defined($terminal->{_md}) && defined($terminal->{_me})) {
		$this->{terminal} = $terminal;
	}

	bless $this, $class;
}

sub turnOnBold {
	my $this = $_[0];
	if(-t STDOUT && defined($this->{terminal})) {
		print $this->{terminal}->Tputs('md', 0);
	}
}

sub turnOffBold {
	my $this = $_[0];
	if(-t STDOUT && defined($this->{terminal})) {
		print $this->{terminal}->Tputs('me', 0);
	}
}

#  Get prefix which should be printed before reported lines
sub getPrefix {
	return "[sbuild]: ";
}

#  Report beginning of compilation
sub reportStartOfCompilation {
	SBuild::Reporter::reportStartOfCompilation(@_);
}

#  It's called when compilation ends
sub reportEndOfCompilation {
	SBuild::Reporter::reportEndOfCompilation(@_);
	
	# -- print time of compilation
	my $this = $_[0];
	if($this->{verbosity} >= 4) {
		print $this->getPrefix . "-----------------------------\n";
		print $this->getPrefix . " Begin : " . $this->printDate($this->getCompilationBeginning) . "\n";
		print $this->getPrefix . " End   : " . $this->printDate($this->getCompilationEnding) . "\n";
		print $this->getPrefix . " Time  : " . $this->printInterval($this->getCompilationTime) . "\n";
	}
	
	# -- print ending mark
	if($this->{verbosity} >= 3) {
		print $this->getPrefix . "-----------------------------\n";
		print $this->getPrefix . "Work done.\n";
	}
}

# Report entering of a task
#   usage: enterTask(task_name)
sub enterTask {
	my $this = $_[0];
	my $task_name = $_[1];
	if($this->{verbosity} >= 4) {
		print $this->getPrefix . "Entering task $task_name\n";
	}
}

# Report leaving of a task
#   Usage: leaveTask(task_name)
sub leaveTask {
	my $this = $_[0];
	my $task_name = $_[1];
	if($this->{verbosity} >= 5) {
		print $this->getPrefix . "Leaving task $task_name\n";
	}
}

# Report a task command
#   Usage: taskCommand(task_name, command)
sub taskCommand {
	my $this = $_[0];
	my $task_name = $_[1];
	my $command = $_[2];
	if($this->{verbosity} >= 1) {
		print "$command\n";
	}
}

# Report a task result
#   Usage: taskResult(task_name, result_flag, result_string)
sub taskResult {
	my $this = $_[0];
	my $task_name = $_[1];
	my $result_flag = $_[2];
	my $result_string = $_[3];
	
	if($this->{verbosity} >= 1){
		$this->turnOnBold;
		if(! ($result_string =~ /^\s*$/)) {
			$result_string =~ s/\n$//;
			print "$result_string\n";
		}
		print "Error!\n" if(! $result_flag);
		$this->turnOffBold;
	}
}

#  Report entering of a stage
#
#  Usage: enterStage($stage_name)
sub enterStage {
	my $this = $_[0];
	my $stage_name = $_[1];

	if($this->{verbosity} >= 3) {
		print $this->getPrefix . "Entering stage $stage_name\n";
	}	
}

#  Report leaving of a stage
#
#  Usage: leaveStage($stage_name)
sub leaveStage {
	my $this = $_[0];
	my $stage_name = $_[1];
	
	if($this->{verbosity} >= 5) {
		print $this->getPrefix . "Leaving stage $stage_name\n";
	}
}

#  Report an error
#
#  Usage: reportError($message)
sub reportError {
	my $this = $_[0];
	my $message = $_[1];
	
	if($this->{verbosity} >= 1) {
		$this->turnOnBold;
		print $this->getPrefix . "Error - $message\n";
		$this->turnOffBold;
	}
}

#  Report and warning
#
#  Usage: reportWarning($message)
sub reportWarning {
	my $this = $_[0];
	my $message = $_[1];
	
	if($this->{verbosity} >= 1) {
		$this->turnOnBold;
		print $this->getPrefix . "Warning - $message\n";
		$this->turnOffBold;
	}
}

#  Report entering of a project
#
#  Usage: enterProject($projectname, $projectpath)
sub enterProject {
	my $this = $_[0];
	my $projectname = $_[1];
	my $projectpath = $_[2];
	
	if($this->{verbosity} >= 2) {
		print $this->getPrefix . "Entering project $projectname at $projectpath\n";
	}
}

#  Report leaving of a project
#
#  Usage: leaveProject($projectname, $projectpath)
sub leaveProject {
	my $this = $_[0];
	my $projectname = $_[1];
	my $projectpath = $_[2];
	
	if($this->{verbosity} >= 5) {
		print $this->getPrefix . "Leaving project $projectname at $projectpath\n";
	}
}

#  Report a broken project (previous stage failed)
#
#  Usage: reportBrokenProject($prjname, $prjpath, $stage)
sub brokenProject {
	my $this = $_[0];
	my $projectname = $_[1];
	my $projectpath = $_[2];
	my $stage = $_[3];

	my $message = "Project $projectname (stage $stage) at path $projectpath is broken.";
	$this->reportError($message);
}

#  Report reading of a repository file
#
#  Usage: reportRepository($repfile)
sub reportRepository {
	my $this = $_[0];
	my $repfile = $_[1];
	
	if($this->{verbosity} >= 2) {
		print $this->getPrefix . "Reading repository $repfile\n";
	}
}

#  Report an installation task
#
#  Usage: reportInstall($message)
sub reportInstall {
	my $this = $_[0];
	my $message = $_[1];
	
	if($this->{verbosity} >= 1) {
		print $this->getPrefix . "Install: $message\n";
	}
}

#  Report an uninstallation task
#
#  Usage: reportInstall($message)
sub reportUninstall {
	my $this = $_[0];
	my $message = $_[1];
	
	if($this->{verbosity} >= 1) {
		print $this->getPrefix . "Uninstall: $message\n";
	}
}

#  Report a cycle in the graph of dependencies of projects
#
#  Usage: reportProjectCycle($prjlist)
sub reportProjectCycle {
	my $this = $_[0];
	my $prjlist = $_[1];

	if($this->{verbosity} >= 1) {
		print $this->getPrefix . "Cycled dependencies:";	
		foreach my $prj (@$prjlist) {
			print " $prj";
		}
		print "\n";
	}	
}

#  Report beginning of parsing of a SMakefile of a project
#
#  Usage: reportProjectParsing($prjname, $prjpath)
sub reportProjectParsing {
	my $this = $_[0];
	my $prjname = $_[1];
	my $prjpath = $_[2];
	
	if($this->{verbosity} >= 3) {
		print $this->getPrefix . "Parse project $prjname at $prjpath\n";
	}	
}

#  Report end of parsing of a project
#
#  Usage: reportEndOfParsing($prjname, $prjpath)
sub reportEndOfParsing {

}

#  Begin checking of a repository
#
#  Usage: reportRepositoryBegin($repository)
sub reportRepositoryBegin {
	my $this = $_[0];
	my $repository = $_[1];
	
	if($this->{verbosity} >= 1) {
		print $this->getPrefix . "Checking of repository $repository:\n";
	}
}

#  Usage: reportRepositoryProjectStatus($repository, $project, $okflag)
sub reportRepositoryProjectStatus {
	my $this = $_[0];
	my $repository = $_[1];
	my $project = $_[2];
	my $okflag = $_[3];
	
	if($okflag) {
		if($this->{verbosity} >= 4) {
			print $this->getPrefix . "    $project\n";
		}
	}
	else {
		if($this->{verbosity} >= 3) {
			print $this->getPrefix . "  ! $project\n";
		}
	}
}

#  Usage: reportRepositoryProjectUnreg($project)
sub reportRepositoryProjectUnreg {
	my $this = $_[0];
	my $project = $_[1];

	if($this->{verbosity} >= 3) {
		print $this->getPrefix . "Repository record of project $project is removed.\n";
	}
}

#  Usage: reportRepositoryEnd($repository)
sub reportRepositoryEnd {

}

sub projectCheckBegin {
	my $this = $_[0];
	
	if($this->{verbosity} >= 1) {
		print $this->getPrefix . "Checking of projects:\n";
	}
}

#  Checking of a project
#
#  Usage: reportProjectRepositoryStatus($project, $path, $okflag)
sub projectRepositoryStatus {
	my $this = $_[0];
	my $project = $_[1];
	my $path = $_[2];
	my $okflag = $_[3];
	
	if($okflag) {
		if($this->{verbosity} >= 4) {
			print $this->getPrefix . "    $project at $path\n";
		}
	}
	else {
		if($this->{verbosity} >= 3) {
			print $this->getPrefix . "  ! $project at $path\n";
		}
	}
}

sub projectCheckEnd {

}

return 1;
