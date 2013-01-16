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

#  SOAP code created from a WSDL specification
package SMakeParser::WsdlRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SBuild::SourceResource;
use SMakeParser::WsdlTask;
use SBuild::SedTask;
use SMakeParser::SoapRecord;

#  Ctor
#
#  Usage: newRecord($mask, $prefix, $srvname, $server, \@extrasrv)
sub newRecord {
	my $class = $_[0];
	# -- handle file mask
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	# -- SOAP prefix
	$this->{prefix} = $_[2];
	$this->{srvname} = $_[3];
	$this->{server} = $_[4];
	if(defined($_[5])) {
		$this->{extrasrv} = [@{$_[5]}];
	}
	else {
		$this->{extrasrv} = [];
	}
	bless $this, $class;
}

#  Ctor - with sed operation
#
#  Usage: newResolverRecordSed($mask, $prefix, $srvname, $server, \@extrasrv, $sedfile, $hdrfile)
sub newRecordSed {
	my $class = $_[0];
	my $this = $class->newRecord($_[1], $_[2], $_[3], $_[4], $_[5]);
	$this->{sedfile} = $_[6];
	$this->{hdrfile} = $_[7];
	return $this;
}

sub getHeaderResources {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $prefix = $this->{prefix};
	
	my $hdrres = SBuild::TargetResource->newResource($prefix . ".h");
	return $hdrres;
}

sub getServiceResources {
	my $this = $_[0];
	my $resource = $_[1];
	my $srvname = $_[2];
	
	my $prefix = $this->{prefix};
	my $file_suffix;	
	if($this->{server}) { $file_suffix = "Service" } else { $file_suffix = "Proxy" }
	my $proxyhres = SBuild::TargetResource->newResource($prefix . $srvname . $file_suffix . ".h");
	my $proxycres = SBuild::TargetResource->newResource($prefix . $srvname . $file_suffix . ".cpp");
	
	return ($proxyhres, $proxycres);
}

sub getSedResources {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $sedres = SBuild::SourceResource->newResource($this->{sedfile});
	my $orighdrres = SBuild::TargetResource->newResource($this->{hdrfile}); 
	
	return ($sedres, $orighdrres);
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

	# -- header resource (the header is generated from the WSDL file)
	my $hdrres = $this->getHeaderResources($resource);
	$map->appendResource($hdrres);
	$map->appendDependency($hdrres->getID, $resource->getID);	

	# -- I must set a special resolver record, because .h file has
	#    a standard record.
	$assembler->getResolver->appendSysRecord(
					SMakeParser::SoapRecord->newRecord(
						$hdrres->getRegExID,
						$this->{prefix},
						$this->{srvname},
						$this->{server}
				));
	
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

	# -- create file resources
	my $hdrres = $this->getHeaderResources($resource);
	my $orighdr;
	my $sedres;
	if(defined($this->{sedfile})) {
		($sedres, $orighdr) = $this->getSedResources($resource);
	}
	else {
		$orighdr = $hdrres;
	}
	
	# -- generate the header form the WSDL specification
	my $wsdltask = SMakeParser::WsdlTask->newTask(
						$resource->getID, $resource,
						[$orighdr], [$resource], [], $this->{prefix});
	$assembler->appendTask("compile", $wsdltask);
	
	# -- change content of the header if a filter is specified
	if(defined($this->{sedfile})) {
		my $sedtask = SBuild::SedTask->newTask(
						$orighdr->getID, $resource,
						[$hdrres], [$orighdr, $sedres], [], $this->{prefix});
		$assembler->appendTask("compile", $sedtask);
	}

	# -- cleaning of the headers
	$assembler->addClean($hdrres);
	if(defined($this->{sedfile})) {
		$assembler->addClean($orighdr);
	}

	# -- append extra services files to clean
	foreach my $exsrv (@{$this->{extrasrv}}) {
		(my $exc, my $exh) = $this->getServiceResources($resource, $exsrv);
		$assembler->addClean($exc);
		$assembler->addClean($exh);
	}

	# -- to force compilation of the utility before compilation of current
	#    project.
	$assembler->addProjectDependency(
						$assembler->getProject->getName, 
						$assembler->getPhase->getFirstStage,
						"wsdl2h", "binpostlink");
	
	return $wsdltask;
}

return 1;
