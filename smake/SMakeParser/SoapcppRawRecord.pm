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

#  Soap header record - used to compile Soap libraries
#
#  Do not use this record to generate a usuall Aveco web service
package SMakeParser::SoapcppRawRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SMakeParser::SoapcppRawTask;

#  Ctor
#
#  Usage: newResolverRecord($mask, $prefix, $c_flag)
sub newRecord {
	my $class = $_[0];
	# -- handle file mask
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	# -- SOAP prefix 	
	$this->{prefix} = $_[2];
	$this->{c_flag} = $_[3];
	bless $this, $class;
}

sub getSoapResources {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $prefix = $this->{prefix};
	my $c_flag = $this->{c_flag};
	my $srcext;
	if($c_flag) { $srcext = '.c'} else { $srcext = '.cpp' }
	
	my $cres = SBuild::TargetResource->newResource($prefix. "C" . $srcext);
	my $clientres = SBuild::TargetResource->newResource($prefix . "Client" . $srcext);
	my $hdrres = SBuild::TargetResource->newResource($prefix . "H.h");
	my $serverres = SBuild::TargetResource->newResource($prefix . "Server" . $srcext);
	my $stubres = SBuild::TargetResource->newResource($prefix . "Stub.h");
	
	return ($cres, $clientres, $hdrres, $serverres, $stubres);
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

	(my $cres, my $clientres, my $hdrres, my $serverres, my $stubres) =
		$this->getSoapResources($resource);
	$map->appendResource($cres);
	$map->appendDependency($cres->getID, $resource->getID);
	
	return 1;
}

#  Process the file - create tasks
#
#  Usage: processResourceSpecial($map, $assembler, $profile, $reporter, $resource)
sub processResourceSpecial {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	# -- generate stub and skeleton code
	my $c_flag = $this->{c_flag};
	my $prefix = $this->{prefix};
	(my $cres, my $clientres, my $hdrres, my $serverres, my $stubres) =
		$this->getSoapResources($resource);
	my $soaptask = SMakeParser::SoapcppRawTask->newTask(
						$resource->getFilename, $resource,
						[$cres, $clientres, $hdrres, $serverres, $stubres],
						[$resource], [], $prefix, $c_flag);
	$assembler->appendTask("compile", $soaptask);
	$assembler->addClean($cres);
	$assembler->addClean($clientres);
	$assembler->addClean($hdrres);
	$assembler->addClean($serverres);
	$assembler->addClean($stubres);
	
	# -- add project dependency to force compilation of the Soap utility
	#    before compilation of current project
	$assembler->addProjectDependency($assembler->getProject->getName, 
	                                 $assembler->getPhase->getFirstStage,
	                                 "soapcpp2", "binpostlink");

	return $soaptask;
}

return 1;
