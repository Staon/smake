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

#  Sun RPC generator record
package SMakeParser::RPCRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SBuild::RPCTask;

#  Ctor
#
#  Usage: newRecord([$mask])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]x$' if(! defined($mask));
	my $this = SMakeParser::ResolverRecord->newRecord($mask);
	bless $this, $class;
}

sub getRPCResources {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $clntres = SBuild::TargetResource->newResource($resource->getPurename . "_clnt.c");
	my $xdrres = SBuild::TargetResource->newResource($resource->getPurename . "_xdr.c");
	my $svcres = SBuild::TargetResource->newResource($resource->getPurename . "_svc.c");
	my $hdrres = SBuild::TargetResource->newResource($resource->getPurename . ".h");
	
	return ($hdrres, $clntres, $svcres, $xdrres);
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
	
	(my $hdrres, my $clntres, my $svcres, my $xdrres) =
		$this->getRPCResources($resource);
	$map->appendResource($hdrres);
	$map->appendResource($clntres);
	$map->appendResource($svcres);
	$map->appendResource($xdrres);
	
	$map->appendDependency($clntres->getID, $resource->getID);
	$map->appendDependency($svcres->getID, $resource->getID);
	$map->appendDependency($xdrres->getID, $resource->getID);
	$map->appendDependency($hdrres->getID, $resource->getID);
	
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

	# -- RPC generation task
	(my $hdrres, my $clntres, my $svcres, my $xdrres) =
		$this->getRPCResources($resource);
	my $rpctask = SBuild::RPCTask->newTask(
						$resource->getFilename, $resource,
						[$hdrres, $clntres, $xdrres, $svcres],
						[$resource], []);
	$assembler->appendTask("compile", $rpctask);

	$assembler->addClean($hdrres);
	$assembler->addClean($clntres);
	$assembler->addClean($xdrres);
	$assembler->addClean($svcres);
		
	return $rpctask;
}

return 1;
