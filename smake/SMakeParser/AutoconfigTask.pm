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

#  Autoconfig task
#
#  This task runs the configure script
package SMakeParser::AutoconfigTask;

use SBuild::CommandTask;

@ISA = qw(SBuild::CommandTask);

#  Ctor
#
#    Usage: newTask($name, $resource, $cmd, $args)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::CommandTask->newTask($_[1], $_[2]);
	$this->{command} = $_[3];

	# -- Autoconfig check - compare stored project path a eventualy rerun configure
	if(defined($_[4]->{autoconfigcheck})) {
		$this->{autoconfigchecktarget} = $_[4]->{autoconfigcheck};
	}
	
	bless $this, $class;
}

#  Get location resource
#
#  Return: file resource of the .smakelocation file
sub getLocationResource() {
	return SBuild::TargetResource->newResource(".smakelocation");
}

#  Expand project names in the string
sub getExpandedCommand {
	my ($this, $profile) = @_;
	return SBuild::Utils::parseProjectString($profile->getRepository, $this->{command});
}

#  Clean task work
#
#  Usage: cleanTask($profile, $reporter, $project, $status)
sub cleanTask {
	my ($this, $profile, $reporter, $project, $status) = @_;
	
	$this->SUPER::cleanTask($profile, $reporter, $project, $status);
	
	if($status && $this->{autoconfigchecktarget}) {
		# -- store new location
		my $locationfile = $this->getLocationResource()->getFullname($profile);
		local * LOCATION;
		return 0 if(! open LOCATION, ">" . $locationfile);
		print LOCATION $project->getPath();
		close LOCATION;
	}
	return 1;
}

#  Get count of commands
#
#  Usage: getCommandCount($profile, $reporter, $project)
#  Return: Count of commands. The default value is 1.
sub getCommandCount {
	my ($this, $profile, $reporter, $project) = @_;
	
	my $runconfigure = 0;
	$this->{commandlist} = [];
	if($this->{autoconfigchecktarget}) {
		my $locationfile = $this->getLocationResource()->getFullname($profile);
		if(-f $locationfile) {
			local * LOCATION;
			if(open LOCATION, "<" . $locationfile) {
				my @lines = <LOCATION>;
				close(LOCATION);
				if($lines[0] ne $project->getPath()) {
					$runconfigure = 1;
					# -- Clean the location file to force run of the config in the future
					#    if the config now fails. The location is stored into the file
					#    in the cleanTask method which is called when the task ends.
					push @{$this->{commandlist}}, $profile->getToolChain->getClean([$locationfile], "");
				}
			}
		}
		else {
			$runconfigure = 1;
		}
	
		# -- create list of commands
		if($runconfigure) {
			# -- compose the list of commands
			push @{$this->{commandlist}}, "if [ -f makefile -o -f Makefile ]; then make " . $this->{autoconfigchecktarget} . " ; else exit 0 ; fi";
			push @{$this->{commandlist}}, $this->getExpandedCommand($profile);
		}
	}
	else {
		push @{$this->{commandlist}}, $this->getExpandedCommand($profile);
	}
	
	return scalar @{$this->{commandlist}}
}

#  Get task command
#  This is a pure virtual method!
#
#  Usage: getCommand($profile, $reporter, $project, $index)
#  Return: Command string
sub getCommand {
	my ($this, $profile, $reporter, $project, $index) = @_;
	return $this->{commandlist}->[$index];
}

#  Append clean tasks if it's needed
#
#  Usage: appendCleanTasks($assembler)
sub appendCleanTasks {
	my ($this, $assembler) = @_;
	$assembler->addClean($this->getLocationResource());
}

return 1;
