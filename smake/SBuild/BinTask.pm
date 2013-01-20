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

# Binary file (executable file) creation target
package SBuild::BinTask;

use SBuild::CompileTask;

@ISA = qw(SBuild::CompileTask);

use SBuild::ExtResource;

#   Ctor
#
#   Usage: newTask($name, $linker_composer, $resource, \@target, \@source, \@deps, \%arguments)
sub newTask {
	my $class = shift;
	my $name = shift;
	my $linker_composer = shift;
	$this = SBuild::CompileTask->newTask($name, @_);
	$this->{linker_composer} = $linker_composer;
	bless $this, $class;
}

#  Get task command
#
#  Usage: getTaskCommand(profile, $reporter, \@targets, \@sources, \@options, \%arguments)
#  Return: Command string
sub getTaskCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $targets = $this->convertToFileList($profile, $_[3]);
	my $sources = $this->convertToFileList($profile, $_[4]);
	my $options = $_[5];
	my $args = $_[6];
	
	# -- compose linking command
	my $libopts = $profile->getProfileStack->getOptions("LIBOPTS", $profile, $reporter);
	return $profile->getToolChain->getLinker($targets, $sources, $options, $args, $libopts);
}

#  Get task options
#
#  Usage: getOptions($profile, $reporter)
#  Return: String of the options
sub getOptions {
	my $profile = $_[1];
	my $reporter = $_[2];
	return $profile->getProfileStack->getOptions("LDFLAGS", $profile, $reporter);
}

#  Initialize task work
#
#  Usage: initTask($profile, $reporter, $project)
sub initTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	# -- append libraries into list of dependencies
	$this->{linker_composer}->prepareProcessing($profile, $reporter);
	my $liblist = $this->{linker_composer}->getListOfLibraryFiles($profile, $reporter);
	if(defined($liblist)) {
		my @reslist = map { SBuild::ExtResource->newResource($_) } @$liblist;
		$this->appendDeps(\@reslist);
		return 1; 
	}
	else {
		return 0;
	}
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
	
	# -- the relink profile
	my $relink = $profile->getProfileStack->getOptions("LD_RELINK", $profile, $reporter);
	if($relink !~ /^\s*$/) {
		return 1;
	}

	# -- redirect to the standard method
	return SBuild::CompileTask::shallBeRun(@_);
}

return 1;
