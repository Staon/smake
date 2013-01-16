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

#  Bison record resolver
package SMakeParser::BisonRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::BisonTask;
use SBuild::RenameTask;
use SBuild::TargetResource;

#  Ctor
#
#  Usage: newRecord([$mask [, $c_flag]])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]y$' if(! defined($mask));
	my $this = SMakeParser::ResolverRecord->newRecord($mask);
	$this->{c_flag} = $_[2];
	bless $this, $class;
}

sub getResources {
	my $this = $_[0];
	my $resource = $_[1];

	my $purename = $resource->getPurename;
	my $tgname;
	my $outlist;
	my $header;
	my ($stackhdr, $lochdr, $poshdr);
	if($this->{c_flag}) {
		$tgname = $purename . ".tab.c";
		$header = $purename . ".tab.h";
		$outlist = $purename . ".output";
		return (
			SBuild::TargetResource->newResource($tgname), 
			SBuild::TargetResource->newResource($header),
			SBuild::TargetResource->newResource($outlist)
		);
	}
	else {
		$tgname = $purename . ".tab.cpp";
		$header = $purename . ".tab.hpp";
		$outlist = $purename . ".output";
		$stackhdr = "stack.hh";
		$lochdr = "location.hh";
		$poshdr = "position.hh";
		return (
			SBuild::TargetResource->newResource($tgname), 
			SBuild::TargetResource->newResource($header),
			SBuild::TargetResource->newResource($outlist)
,
			SBuild::TargetResource->newResource($stackhdr),
			SBuild::TargetResource->newResource($lochdr)
,
			SBuild::TargetResource->newResource($poshdr)
,
		);
	}
}

#  Get a resource and create dependent resources (which are created from
#  this resource)
#
#  Usage: extendMapSpecial($map, $assembler, $profile, $reporter, $resource)
sub extendMapSpecial {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	# -- create resources
	(my $tgres, my $hdrres) = $this->getResources($resource);
	$map->appendResource($tgres);
	$map->appendResource($hdrres);
	
	# -- specify resource dependencies
	$map->appendDependency($tgres->getID, $resource->getID);
	$map->appendDependency($hdrres->getID, $resource->getID);
	
	return 1;
}

#  Process the file - create tasks
#
#  Usage: resolveResourceSpecial($map, $assembler, $profile, $reporter, $resource)
sub processResourceSpecial {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	# -- create resources
	my ($tgres, $hdrres, $outlist, $stackhdr, $lochdr, $poshdr) = $this->getResources($resource);

	# -- create the Bison task
	my $bisontask = SBuild::BisonTask->newTask($resource->getFilename, $resource,
	                                           [$tgres], [$resource], []);
	$assembler->appendTask("compile", $bisontask);
	
	# -- files to clean
	$assembler->addClean($tgres);
	$assembler->addClean($hdrres);
	$assembler->addClean($outlist);
	$assembler->addClean($stackhdr) if(defined($stackhdr));
	$assembler->addClean($lochdr) if(defined($lochdr));
	$assembler->addClean($poshdr) if(defined($poshdr));
	
	return $bisontask;
}

return 1;
