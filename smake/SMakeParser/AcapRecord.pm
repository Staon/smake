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

#  resolver of akbc(d) files
package SMakeParser::AcapRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SMakeParser::AcapTask;
use SMakeParser::EmptyRecord;
use SBuild::InstallTask;

#  Ctor
#
#  Usage: newRecord([$mask, [$install]])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]acapc$' if(! defined($mask));
	my $this = SMakeParser::ResolverRecord->newRecord($mask);
	$this->{install} = $_[2];
	bless $this, $class;
}

sub getDefinitionResource {
	my $this = $_[0];
	my $resource = $_[1];
	
	return SBuild::TargetResource->newResource($resource->getPurename . ".acap"); 
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

	# -- create the definition resource
	my $acapres = $this->getDefinitionResource($resource);
	$map->appendResource($acapres);
	$map->appendDependency($acapres->getID, $resource->getID);
	
	# -- I must set a special resolver record, because .h file has
	#    a standard record.
	$assembler->getResolver->appendSysRecord(
					SMakeParser::EmptyRecord->newRecord($acapres->getRegExID));
	
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
	my $acapres = $this->getDefinitionResource($resource);
	my $acaptask = SMakeParser::AcapTask->newTask(
	                      $resource->getFilename, $resource,
	                      [$acapres], [$resource], []);
	$assembler->appendTask("compile", $acaptask);
	
	# -- clean generated files
	$assembler->addClean($acapres);

	# -- installation task
	if(defined($this->{install})) {
		my $insttask = SBuild::InstallTask->newTask(
							"install:" . $acapres->getFilename,
							$resource,
							$this->{install},
							$acapres);
		$assembler->appendInstallTask($insttask);
	}

	# -- add project dependency to force compilation of the utility before
	#    current project
	$assembler->addProjectDependency($assembler->getProject->getName, 
	                                 $assembler->getPhase->getFirstStage,,
	                                 "acap_compile", "binpostlink");

	return $acaptask;
}

return 1;
