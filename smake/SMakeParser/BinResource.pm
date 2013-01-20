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

#  Binary main resource
package SMakeParser::BinResource;

use SMakeParser::BinaryResource;

@ISA = qw(SMakeParser::BinaryResource);

use SBuild::TargetResource;
use SBuild::SourceResource;
use SBuild::BinTask;
use SMakeParser::VersionResource;
use SMakeParser::WdbLinkTask;
use SBuild::InstallTask;

#  Ctor
#
#  Usage: newResource($binname, $photon, \%args)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::BinaryResource->newResource($_[1]);
	$this->{photon} = $_[2];
	$this->setArguments($_[3]);
	bless $this, $class;
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMapBinary {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	my $arguments = $this->getArguments;
	
	# -- Check if a help is filled when the binary is should be installed
	if(defined($arguments->{'install'}) && 
	   ! defined($arguments->{'usefile'}) && 
	   ! defined($arguments->{'version'}) &&  # -- backward compatibility
	   ! defined($arguments->{'help'})) {
		die "The executable file '" . $this -> getFilename . 
		    "'should be installed into the runtime but there is no help message!";
	}

	# -- use message (QNX specific)
#	my $dontusage = 0;
#	my $usesrc = $arguments->{'usefile'};
#	if(defined($usesrc)) {
#		my $useres = SBuild::SourceResource->newResource($usesrc);
#		my $usageres = SMakeParser::UsageResource->newResource(
#							$this, $this->getExeResource($profile), $useres, 1);
#		$map->appendResource($usageres);
#		$map->appendDependency($usageres->getID, $this->getID);
#		$dontusage = 1;
#	}
	
	# -- compile SVN and smake related info into the binary file (Aveco specific)
#	my $makeversion = $arguments -> {'makeversion'};
#	if(defined($makeversion)) {
#		if($makeversion eq "C" || $makeversion eq "c") {
#			# -- compile only C version info
#			my $verres = SMakeParser::VersionResource->newResource(
#								$this, $this->getExeResource($profile), $dontusage, 1);
#			$map->appendResource($verres);
#		}
#		# -- else: don't compile version info
#	}
#	else {
#		# -- default: compile C++ version info
#		my $verres = SMakeParser::VersionResource->newResource(
#								$this, $this->getExeResource($profile), $dontusage);
#		$map->appendResource($verres);
#	}

	# -- append photon profile if this binary file is a photon application
	if($this->{photon}) {
		# -- Append photon compilation profile. The profile must be
		#    stored to the project because the changeProject method
		#    isn't called to tasks' profiles.
		my $phprof = $profile->getNamedProfiles->getNamedProfile("photon");
		$assembler->getProject->appendProfile($phprof);
	}
	
	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResourceBinary {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	my $objfiles = $assembler->getObjectFiles;
	$this->{objfiles} = $objfiles;

	# -- linking profile
	my $linker_composer = $assembler->getLinkerComposer;
	my $link_profile = SMakeParser::LibLinkProfile->newCompileProfile($linker_composer);
	$this->appendProfile($link_profile);

	# -- linking task
	my $exeres = $this->getExeResource($profile);
	my $bintask = SBuild::BinTask->newTask(
						$this->getBinTaskName,
						$linker_composer, 
						$this,
						[$exeres], $objfiles, [], $this->getArguments);
	$assembler->appendTask("link", $bintask);

	if($this->{photon}) {
		my $mark = $this->setTaskMark("wdblink:" . $this->getBinTaskName);
		my $wdbtask = SMakeParser::WdbLinkTask->newTask(
						"wdblink:" . $this->getBinTaskName, $this,
						$mark, $exeres);
		$assembler->appendTask("link", $wdbtask);
	}
	
	# -- library clean task
	$assembler->addClean($exeres);
	
	# -- binary installation task
	my $args = $this->getArguments;
	my $install_dir = $args->{install};
	if(defined($install_dir)) {
		my $insttask = SBuild::InstallTask->newTask(
						"install:" . $this->getBinTaskName, $this,
						$install_dir, $exeres);
		$assembler->appendInstallTask($insttask);
	}

	return $bintask;
} 

sub getObjects {
	my $this = $_[0];
	return $this->{objfiles};
}

return 1;
