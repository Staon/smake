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

#  Compile version information
package SMakeParser::VersionTask;

use SBuild::CommandTask;

@ISA = qw(SBuild::CommandTask);

use SMakeParser::ProfileUtils;

#  Ctor
#
#  Usage: newTask($binres, $resource, $exeres, $verres, $usageres, $vendor, $dontusage)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask("version" . $_[1]->getID, $_[2]);
	$this->{binres} = $_[1];
	$this->{exeres} = $_[3];
	$this->{verres} = $_[4];
	$this->{usageres} = $_[5];
	$this->{vendor} = $_[6];
	$this->{dontusage} = $_[7];
	bless $this, $class;
}

#  Decide if the task should be run
#
#  Usage: shallBeRun($profile, $reporter, $project)
#  Return: True when the project shall be run
sub shallBeRun {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	my $objects = $this->convertToFileList($profile, $this->{binres}->getObjects);
	my $decider = $profile->getDecider;
	return $decider->isOutOfTime([$this->{exeres}->getFullname($profile)], $objects);
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
	
	# -- get path of the makeversion utility
	my $verutil = SMakeParser::ProfileUtils::getFilePath($profile, "makeversion", "makeversion");

	# -- get makeversion arguments
	my $args = $profile->getProfileStack->getOptions("MAKEVERSION_ARGS", $profile, $reporter);

	# -- compose the command
	my $command;
	$command = "$verutil -a " . $this->{exeres}->getFullname($profile) . 
	           " -V '" . $this->{vendor} .
    	   	   "' -o " . 
    	       $this->{verres}->getFullname($profile) . 
		       " --prjname='" . $project->getName . 
		       "' --prjpath='" . $project->getPath . "'";
	$command = "$command -u " . $this->{usageres}->getFullname($profile)
		if(! $this->{dontusage});		       
	return "$command $args";
}

return 1;
