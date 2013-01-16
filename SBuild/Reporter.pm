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

package SBuild::Reporter;

# Create new reporter (ctor)
sub newReporter {
	my $class = shift;
	my $this = {};
	bless $this, $class;
}

#  Report beginning of compilation
sub reportStartOfCompilation {
	my $this = $_[0];
	$this->{beginning} = time;
}

#  It's called when compilation ends
sub reportEndOfCompilation {
	my $this = $_[0];
	$this->{ending} = time;
}

# Report entering of a task
#   usage: enterTask(task_name)
sub enterTask {
	die "It's not possible to invoke pure virtual method Reporter::enterTask!";
}

# Report leaving of a task
#   Usage: leaveTask(task_name)
sub leaveTask {
	die "It's not possible to invoke pure virtual method Reporter::leaveTask!";
}

# Report a task command
#   Usage: taskCommand(task_name, command)
sub taskCommand {
	die "It's not possible to invoke pure virtual method Reporter::taskCommand!";

}

# Report a task result
#   Usage: taskResult(task_name, result_flag, result_string)
sub taskResult {
	die "It's not possible to invoke pure virtual method Reporter::taskResult!";
}

#  Report entering of a stage
#
#  Usage: enterStage($stage_name)
sub enterStage {
	die "It's not possible to invoke pure virtual method Reporter::enterStage!";
}

#  Report leaving of a stage
#
#  Usage: leaveStage($stage_name)
sub leaveStage {
	die "It's not possible to invoke pure virtual method Reporter::leaveStage!";
}

#  Report an error
#
#  Usage: reportError($message)
sub reportError {
	die "It's not possible to invoke pure virtual method Reporter::reportError!";
}

#  Report and warning
#
#  Usage: reportWarning($message)
sub reportWarning {
	die "It's not possible to invoke pure virtual method Reporter::reportWarning!";
}

#  Report entering of a project
#
#  Usage: enterProject($projectname, $projectpath)
sub enterProject {
	die "It's not possible to invoke pure virtual method Reporter::enterProject!";
}

#  Report leaving of a project
#
#  Usage: leaveProject($projectname, $projectpath)
sub leaveProject {
	die "It's not possible to invoke pure virtual method Reporter::leaveProject!";
}

#  Report a broken project (previous stage failed)
#
#  Usage: reportBrokenProject($prjname, $prjpath, $stage)
sub brokenProject {
	die "It's not possible to invoke pure virtual method Reporter::reportBrokenProject!";
}

#  Report reading of a repository file
#
#  Usage: reportRepository($repfile)
sub reportRepository {
	die "It's not possible to invoke pure virtual method Reporter::reportRepository!";
}

#  Report an installation task
#
#  Usage: reportInstall($message)
sub reportInstall {
	die "It's not possible to invoke pure virtual method Reporter::reportInstall!";
}

#  Report an uninstallation task
#
#  Usage: reportInstall($message)
sub reportUninstall {
	die "It's not possible to invoke pure virtual method Reporter::reportUninstall!";
}

#  Report a cycle in the graph of dependencies of projects
#
#  Usage: reportProjectCycle($prjlist)
sub reportProjectCycle {
	die "It's not possible to invoke pure virtual method Reporter::reportCycle!";
}

#  Report beginning of parsing of a SMakefile of a project
#
#  Usage: reportProjectParsing($prjname, $prjpath)
sub reportProjectParsing {
	die "It's not possible to invoke pure virtual method Reporter::reportProjectParsing!";
}

#  Report end of parsing of a project
#
#  Usage: reportEndOfParsing($prjname, $prjpath)
sub reportEndOfParsing {
	die "It's not possible to invoke pure virtual method Reporter::endOfParsing!";
}

#  Begin checking of a repository
#
#  Usage: reportRepositoryBegin($repository)
sub reportRepositoryBegin {
	die "It's not possible to invoke pure virtual method Reporter::reportRepositoryBegin!";
}

#  Usage: reportRepositoryProjectStatus($repository, $project, $okflag)
sub reportRepositoryProjectStatus {
	die "It's not possible to invoke pure virtual method Reporter::reportRepositoryProjectStatus!";
}

#  Usage: reportRepositoryProjectUnreg($project)
sub reportRepositoryProjectUnreg {
	die "It's not possible to invoke pure virtual method Reporter::reportRepositoryProjectUnreg!";
}

#  Usage: reportRepositoryEnd($repository)
sub reportRepositoryEnd {
	die "It's not possible to invoke pure virtual method Reporter::reportRepositoryEnd!";
}

sub projectCheckBegin {
	die "It's not possible to invoke pure virtual method Reporter::projectCheckBegin!";
}

#  Checking of a project
#
#  Usage: reportProjectRepositoryStatus($project, $path, $okflag)
sub projectRepositoryStatus {
	die "It's not possible to invoke pure virtual method Reporter::projectRepositoryStatus!";
}

sub projectCheckEnd {
	die "It's not possible to invoke pure virtual method Reporter::reportProjectCheckingEnd!";
}

#  Get local time when the compilation starts
#
#  Returns: same as the localtime function
sub getCompilationBeginning {
	my $this = $_[0];
	return localtime($this->{beginning});
}

#  Get local time when the compilation ends
#
#  Returns: same as the localtime function
sub getCompilationEnding {
	my $this = $_[0];
	return localtime($this->{ending});
}

#  Get time of compilation
#
#  Returns: ($sec, $min, $hour)
sub getCompilationTime {
	my $this = $_[0];
	
	my $beg = $this->{beginning};
	my $end = $this->{ending};
	
	my $interval = $end - $beg;

	# -- compute time of compilation
	my $retval = {};
	my $sec = $interval % 60;
	$interval = int($interval / 60);
	my $min = $interval % 60;
	my $hour = int($interval / 60);
	
	return ($sec, $min, $hour);
}

sub printDate {
	return sprintf "%02d:%02d:%02d %04d/%02d/%02d", $_[3], $_[2], $_[1], $_[6] + 1900, $_[5] + 1, $_[4];
}

sub printInterval {
	return sprintf "%02d:%02d:%02d", $_[3], $_[2], $_[1];
}

return 1;
