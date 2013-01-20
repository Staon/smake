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

#  A compilation phase (a group of stages)
package SMakeParser::Phase;

use SBuild::CleanTask;
use SBuild::CleanDirTask;

#  Ctor
#
#  Usage: newPhase($name)
sub newPhase {
	my $class = $_[0];
	my $this = {
		name => $_[1],
		objlist => [],
		cleanlist => [],
		depcleandirs => []
	};
	bless $this, $class;
}

#  Create dependencies between phase's stages
#
#  Usage: composeDependencies($assembler)
sub composeDependencies {
	my $this = $_[0];
	my $assembler = $_[1];
	my $name = $this->{name};

	$assembler->addStageDependency("${name}postlink", "${name}link");
	$assembler->addStageDependency("${name}link", "${name}prelink");
	$assembler->addStageDependency("${name}prelink", "${name}postcompile");
	$assembler->addStageDependency("${name}postcompile", "${name}compile");
	$assembler->addStageDependency("${name}compile", "${name}precompile");
	
	$assembler->addStageDependency("clean", "${name}clean");
	$assembler->addStageDependency("depclean", "${name}depclean");
	$assembler->addStageDependency("${name}clean", "${name}depclean");
}

#  Get name of the phase
sub getName {
	my $this = $_[0];
	return $this->{name};
}

#  Get name of raw stage
#
#  Usage: getRawStage($phstage)
sub getRawStage {
	my $this = $_[0];
	my $phstage = $_[1];
	my $name = $this->{name};
	return "${name}${phstage}";
}

#  Get first compilation stage
sub getFirstStage {
	my $this = $_[0];
	my $name = $this->{name};
	return "${name}precompile";
}

#  Get last compilation stage
sub getLastStage {
	my $this = $_[0];
	my $name = $this->{name};
	return "${name}postlink";
}

#  Get clean stage
sub getCleanStage {
	my $this = $_[0];
	my $name = $this->{name};
	return "${name}clean";
}

#  Make this phase dependant on another phase
#
#  Usage: makeDependent($assembler, $phase)
sub makeDependent {
	my $this = $_[0];
	my $assembler = $_[1];
	my $phase = $_[2];

	$assembler->addStageDependency($this->getFirstStage, $phase->getLastStage);	
}

#  Append a new task
#
#  Usage: appendTask($assembler, $stage, $task)
sub appendTask {
	my $this = $_[0];
	my $assembler = $_[1];
	my $stage = $_[2];
	my $task = $_[3];
	
	$assembler->appendRawTask($this->{name} . $stage, $task);
}

#  Append a new task
#
#  Usage: getTask($assembler, $stage, $taskname)
sub getTask {
	my $this = $_[0];
	my $assembler = $_[1];
	my $stage = $_[2];
	my $taskname = $_[3];
	
	return $assembler->getRawTask($this->{name} . $stage, $taskname);
}

#  Add a task dependency
#
#  Usage: addDependency($assembler, $stage, $srctask, $tgtask)
#  Note:  the tasks must exist before calling of this method!
sub addDependency {
	my $this = $_[0];
	my $assembler = $_[1];
	my $stage = $_[2];
	my $srctask = $_[3];
	my $tgtask = $_[4];
	
	# -- add the dependency
	$assembler->addRawDependency($this->{name} . $stage, $srctask, $tgtask);
}

#  Add a file into the object list
#
#  Usage: addObject($file)
sub addObject {
	my $this = $_[0];
	my $file = $_[1];
	push @{$this->{objlist}}, $file;
}

#  Get and clean the object list
#
#  Return: \@objlist
sub getObjectList {
	my $this = $_[0];
	my $objlist = $this->{objlist};
	$this->{objlist} = undef;
	return $objlist;
}

#  Add a file into the clean list
#
#  Usage: addClean($file)
sub addClean {
	my $this = $_[0];
	my $file = $_[1];
	push @{$this->{cleanlist}}, $file;
}

#  Add a directory to clean dependencies
#
#  Usage: addDepCleanDir($dir)
sub addDepCleanDir {
	my $this = $_[0];
	my $dir = $_[1];
	my $depcleandirs = $this->{depcleandirs};
	
	# -- try to find the directory
	my @ret = grep { $_->isEqual($dir) } @$depcleandirs;
	push @$depcleandirs, $dir if(! @ret);
}

#  Compose tasks and stages of the phase
#
#  Usage: flushPhase($assembler)
sub flushPhase {
	my $this = $_[0];
	my $assembler = $_[1];
	my $name = $this->{name};
	
	# -- create clean stage
	if(@{$this->{cleanlist}}) {
		my $cleantask = SBuild::CleanTask->newTask("${name}clean", undef, $this->{cleanlist});
		$assembler->appendRawTask("${name}clean", $cleantask);
	}
	# -- create depclean stage
	if(@{$this->{depcleandirs}}) {
		my $cleantask = SBuild::CleanDirTask->newTask("${name}depclean", undef, $this->{depcleandirs});
		$assembler->appendRawTask("${name}depclean", $cleantask);
	}
}

#  Check where some compilation task exists
#
#  Usage: isCompileEmpty($assembler)
sub isCompileEmpty {
	my $this = $_[0];
	my $assembler = $_[1];
	my $name = $this->{name};
	my $project = $assembler->getProject;
	return $project->isStageEmpty("${name}precompile") &&
	       $project->isStageEmpty("${name}compile") &&
	       $project->isStageEmpty("${name}postcompile");
}

#  Check whether some link task exists
sub isLinkEmpty {
	my $this = $_[0];
	my $assembler = $_[1];
	my $name = $this->{name};
	my $project = $assembler->getProject;
	
	return $project->isStageEmpty("${name}prelink") &&
	       $project->isStageEmpty("${name}link") &&
	       $project->isStageEmpty("${name}postlink");
}

#  Check whether some clean task exist
sub isCleanEmpty {
	my $this = $_[0];
	my $assembler = $_[1];
	my $name = $this->{name};
	my $project = $assembler->getProject;
	return $project->isStageEmpty("${name}clean") &&
	       $project->isStageEmpty("${name}depclean");
}

return 1;
