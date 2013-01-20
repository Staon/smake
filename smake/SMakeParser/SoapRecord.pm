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

#  Standard gSoap header record
package SMakeParser::SoapRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SMakeParser::SoapcppTask;
use SBuild::PreprocProfile;

#  Ctor
#
#  Usage: newRecord($mask, $prefix, $srvname, $server)
sub newRecord {
	my $class = $_[0];
	# -- handle file mask
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	# -- SOAP prefix 	
	$this->{prefix} = $_[2];
	$this->{srvname} = $_[3];
	$this->{server} = $_[4];
	bless $this, $class;
}

sub getSoapResources {
	my $this = $_[0];
	my $resource = $_[1];

	my $prefix = $this->{prefix};
	my $srvname = $this->{srvname};
		
	# -- prepare filenames
	my $cres = SBuild::TargetResource->newResource($prefix . "C.cpp");
	my $hres = SBuild::TargetResource->newResource($prefix . "H.h");
	my $stubres = SBuild::TargetResource->newResource($prefix . "Stub.h");
	my $nsmapres = SBuild::TargetResource->newResource($prefix . ".nsmap");
	my $file_suffix;
	if($this->{server}) { $file_suffix = "Service" } else { $file_suffix = "Proxy" }
	my $proxyhres = SBuild::TargetResource->newResource($prefix . $srvname . $file_suffix . ".h");
	my $proxycres = SBuild::TargetResource->newResource($prefix . $srvname . $file_suffix . ".cpp");
	
	return ($cres, $hres, $stubres, $nsmapres, $proxyhres, $proxycres);
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

	(my $cres, my $hres, my $stubres, my $nsmapres, my $proxyhres, my $proxycres) =
		$this->getSoapResources($resource);
		
	# -- proxy/service source file
	$map->appendResource($proxycres);
	$map->appendDependency($proxycres->getID, $resource->getID);
	# -- proxy/service header file
	$map->appendResource($proxyhres);
	$map->appendDependency($proxyhres->getID, $resource->getID);

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
	(my $cres, my $hres, my $stubres, my $nsmapres, my $proxyhres, my $proxycres) =
		$this->getSoapResources($resource);
	my $soaptask = SMakeParser::SoapcppTask->newTask(
						$resource->getFilename, $resource,
						[$cres, $hres, $stubres, $nsmapres, $proxyhres, $proxycres],
						[$resource], [], $this->{prefix}, $this->{server});
	$assembler->appendTask("compile", $soaptask);
	
	# -- clean generated files
	$assembler->addClean($cres);
	$assembler->addClean($hres);
	$assembler->addClean($stubres);
	$assembler->addClean($nsmapres);
	$assembler->addClean($proxyhres);
	$assembler->addClean($proxycres);

	# -- set WITH_NOGLOBAL macro - to avoid compilation of the global symbols (they
	#    are a part of the SOAP libraries).
	my $pprof = SBuild::PreprocProfile->newCompileProfile("WITH_NOGLOBAL");
	$assembler->getProject->appendProfile($pprof);

	# -- add project dependency to force compilation of the utility before
	#    current project
	$assembler->addProjectDependency($assembler->getProject->getName, 
	                              $assembler->getPhase->getFirstStage,
	                              "soapcpp2", "binpostlink");

	return $soaptask;
}

return 1;
