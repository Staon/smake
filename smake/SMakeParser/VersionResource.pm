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

#  Pseudoresource to implement version generator
package SMakeParser::VersionResource;

use SMakeParser::PseudoResource;

@ISA = qw(SMakeParser::PseudoResource);

use SBuild::TargetResource;
use SMakeParser::UsageResource;
use SMakeParser::VersionTask;

#  Ctor
#
#  newResource($binres, $exeres, $dontusage, $cflag)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::PseudoResource->newResource("version:" . $_[1]->getPurename);
	$this->{binres} = $_[1];
	$this->{exeres} = $_[2];
	$this->{dontusage} = $_[3];
	$this->{cflag} = $_[4];
	bless $this, $class;
}

sub getVersionResources {
	my $this = $_[0];

	my $purename = $this->{binres}->getPurename;
	my $versrc;
	if($this->{cflag}) {
		$versrc = SBuild::TargetResource->newResource($purename . ".ver.c");
	}
	else {
		$versrc = SBuild::TargetResource->newResource($purename . ".ver.cpp");
	}
	my $verusage = SBuild::TargetResource->newResource($purename . ".usage");
	return ($versrc, $verusage);
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	# -- append version resources
	(my $versrc, my $verusage) = $this->getVersionResources;
	
	# -- generated version C source
	$versrc->setProfileList($this->getProfileList);
	$map->appendResource($versrc);
	$map->appendDependency($versrc->getID, $this->getID);
	
	# -- usage message
	if(! $this->{dontusage}) {
		my $useres = SMakeParser::UsageResource->newResource(
							$this->{binres}, $this->{exeres}, $verusage, 0);
		$map->appendResource($useres);
		$map->appendDependency($useres, $assembler->getMainResource);
	}
	
	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	(my $versrc, my $verusage) = $this->getVersionResources;
	my $vertask = SMakeParser::VersionTask->newTask(
							$this->{binres}, $this,
							$this->{exeres},
							$versrc, $verusage,
							"Aveco s.r.o.",
							$this->{dontusage});
	$assembler->appendTask("compile", $vertask);

	$assembler->addClean($versrc);
	$assembler->addClean($verusage) if(! $this->{dontusage});;

	# -- add project dependency to force compilation of the utility before
	#    current project
	$assembler->addProjectDependency($assembler->getProject->getName, 
                                     $assembler->getPhase->getFirstStage,
	                                 "makeversion", "binpostlink");
	
	if(! $this->{cflag}) {
		$assembler->addLink(["oversion.lib", "datstr.lib", "ondrart_ios.lib"]);
	}
	
	return $vertask;
} 

return 1;
