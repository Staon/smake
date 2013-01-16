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

# Generic compilation task
#
#   The object contains 3 lists:
#      compile_sources .. list of sources which are part of compilation
#                         processes (i.e. *.c or *.cpp files).
#      compile_deps ..... list of files which the task is dependent on but
#                         it's not part of the compilation command (i.e. *.h).
#      targets .......... list of target files
package SBuild::CompileTask;

use SBuild::CommandTask;
use SBuild::Utils;

@ISA = qw(SBuild::CommandTask);

#  Ctor
#
#    Usage: newTask($name, $resource, \@targets, \@sources, \@deps, \%args)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::CommandTask->newTask($_[1], $_[2]);
	$this->{targets} = $_[3];
	$this->{compile_sources} = $_[4];
	$this->{compile_deps} = $_[5];
	if(defined($_[6])) {
		$this->{arguments} = $_[6];
	}
	else {
		$this->{arguments} = {};
	}
	bless $this, $class;
}

#  Append new targets
#
#  Usage: appendTargets($target | \@targets)
sub appendTargets {
	my $this = $_[0];
	my $newtgs = SBuild::Utils::getArrayRef($_[1]);
	push @{$this->{targets}}, @$newtgs;
}

#  Get compilation targets
sub getTargets {
	my $this = $_[0];
	return $this->{targets};
}

#  Append new sources
#
#  Usage: appendSources($source | \@sources)
sub appendSources {
	my $this = $_[0];
	my $newsrcs = SBuild::Utils::getArrayRef($_[1]);
	push @{$this->{compile_sources}}, @$newsrcs;
}

#  Append new compile dependencies
#
#  Usage: appendDeps($dep | \@deps)
sub appendDeps {
	my $this = $_[0];
	my $newdeps = SBuild::Utils::getArrayRef($_[1]);
	push @{$this->{compile_deps}}, @$newdeps;
}

#  Decide if the task should be run
#
#  Usage: shallBeRun($profile, $reporter, $project)
#  Return: True when the project shall be run
sub shallBeRun {
	my $this = $_[0];
	my $profile= $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $targets = $this->convertToFileList($profile, $this->{targets});
	my $sources = $this->convertToFileList($profile, $this->{compile_sources});
	my $deps = $this->convertToFileList($profile, $this->{compile_deps});
	
	my $decider = $profile->getDecider;
	return $decider->isOutOfTime($targets, [@$sources, @$deps]);
}

#  Get task command
#  This is a pure virtual method!
#
#  Usage: getCommand($profile, $reporter, $project)
#  Return: Command string
sub getCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	# Get command options
    my $options = $this->getOptions($profile, $reporter);
	# Get task command
	return $this->getTaskCommand($profile, $reporter,
		                         $this->{targets}, 
		                         $this->{compile_sources},
		                         $options,
		                         $this->{arguments});
}

#  Get taks command
#  This is a pure virtual method!
#
#  Usage: getTaskCommand($profile, $reporter, \@targets, \@sources, $options)
#  Return: Command string
sub getTaskCommand {
	die("Pure virtual method CompileTask::getTaskCommand cannot be called.\n");
}

#  Get task options
#
#  Usage: getOptions($profile, $reporter)
#  Return: String of the options
sub getOptions {
	return "";
}

return 1;
