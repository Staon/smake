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

#  Reporter which contains several reporters
package SMakeParser::ContainerReporter;

use SBuild::Reporter;

@ISA = qw(SBuild::Reporter);

#  Ctor
#
#  Usage newReporter(\@reporters)
sub newReporter {
	my $class = $_[0];
	my $this = SBuild::Reporter->newReporter;
	$this->{reporters} = $_[1];
	bless $this, $class;
}

sub redirectToReporters {
	my $this = shift;
	my $fce = shift;
	foreach my $reporter (@{$this->{reporters}}) {
		$reporter->$fce(@_);
	}
}

#  Report beginning of compilation
sub reportStartOfCompilation {
	SBuild::Reporter::reportStartOfCompilation(@_);
	my $this = shift;
	$this->redirectToReporters("reportStartOfCompilation", @_);
}

#  It's called when compilation ends
sub reportEndOfCompilation {
	SBuild::Reporter::reportEndOfCompilation(@_);
	my $this = shift;
	$this->redirectToReporters("reportEndOfCompilation", @_);
}

# Report entering of a task
#   usage: enterTask(task_name)
sub enterTask {
	my $this = shift;
	$this->redirectToReporters("enterTask", @_);
}

# Report leaving of a task
#   Usage: leaveTask(task_name)
sub leaveTask {
	my $this = shift;
	$this->redirectToReporters("leaveTask", @_);
}

# Report a task command
#   Usage: taskCommand(task_name, command)
sub taskCommand {
	my $this = shift;
	$this->redirectToReporters("taskCommand", @_);
}

# Report a task result
#   Usage: taskResult(task_name, result_flag, result_string)
sub taskResult {
	my $this = shift;
	$this->redirectToReporters("taskResult", @_);
}

#  Report entering of a stage
#
#  Usage: enterStage($stage_name)
sub enterStage {
	my $this = shift;
	$this->redirectToReporters("enterStage", @_);
}

#  Report leaving of a stage
#
#  Usage: leaveStage($stage_name)
sub leaveStage {
	my $this = shift;
	$this->redirectToReporters("leaveStage", @_);
}

#  Report an error
#
#  Usage: reportError($message)
sub reportError {
	my $this = shift;
	$this->redirectToReporters("reportError", @_);
}

#  Report and warning
#
#  Usage: reportWarning($message)
sub reportWarning {
	my $this = shift;
	$this->redirectToReporters("reportWarning", @_);
}

#  Report entering of a project
#
#  Usage: enterProject($projectname, $projectpath)
sub enterProject {
	my $this = shift;
	$this->redirectToReporters("enterProject", @_);
}

#  Report leaving of a project
#
#  Usage: leaveProject($projectname, $projectpath)
sub leaveProject {
	my $this = shift;
	$this->redirectToReporters("leaveProject", @_);
}

#  Report a broken project (previous stage failed)
#
#  Usage: reportBrokenProject($prjname, $prjpath, $stage)
sub brokenProject {
	my $this = shift;
	$this->redirectToReporters("brokenProject", @_);
}

#  Report reading of a repository file
#
#  Usage: reportRepository($repfile)
sub reportRepository {
	my $this = shift;
	$this->redirectToReporters("reportRepository", @_);
}

#  Report an installation task
#
#  Usage: reportInstall($message)
sub reportInstall {
	my $this = shift;
	$this->redirectToReporters("reportInstall", @_);
}

#  Report an uninstallation task
#
#  Usage: reportInstall($message)
sub reportUninstall {
	my $this = shift;
	$this->redirectToReporters("reportUninstall", @_);
}

#  Report a cycle in the graph of dependencies of projects
#
#  Usage: reportProjectCycle($prjlist)
sub reportProjectCycle {
	my $this = shift;
	$this->redirectToReporters("reportProjectCycle", @_);
}

#  Report beginning of parsing of a SMakefile of a project
#
#  Usage: reportProjectParsing($prjname, $prjpath)
sub reportProjectParsing {
	my $this = shift;
	$this->redirectToReporters("reportProjectParsing", @_);
}

#  Report end of parsing of a project
#
#  Usage: reportEndOfParsing($prjname, $prjpath)
sub reportEndOfParsing {
	my $this = shift;
	$this->redirectToReporters("reportEndOfParsing", @_);
}

#  Begin checking of a repository
#
#  Usage: reportRepositoryBegin($repository)
sub reportRepositoryBegin {
	my $this = shift;
	$this->redirectToReporters("reportRepositoryBegin", @_);
}

#  Usage: reportRepositoryProjectStatus($repository, $project, $okflag)
sub reportRepositoryProjectStatus {
	my $this = shift;
	$this->redirectToReporters("reportRepositoryProjectStatus", @_);
}

#  Usage: reportRepositoryProjectUnreg($project)
sub reportRepositoryProjectUnreg {
	my $this = shift;
	$this->redirectToReporters("reportRepositoryProjectUnreg", @_);
}

#  Usage: reportRepositoryEnd($repository)
sub reportRepositoryEnd {
	my $this = shift;
	$this->redirectToReporters("reportRepositoryEnd", @_);
}

sub projectCheckBegin {
	my $this = shift;
	$this->redirectToReporters("projectCheckBegin", @_);
}

#  Checking of a project
#
#  Usage: reportProjectRepositoryStatus($project, $okflag)
sub projectRepositoryStatus {
	my $this = shift;
	$this->redirectToReporters("projectRepositoryStatus", @_);
}

sub projectCheckEnd {
	my $this = shift;
	$this->redirectToReporters("projectCheckEnd", @_);
}

return 1;
