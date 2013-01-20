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

#  Lemon parser record
package SMakeParser::LemonRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SMakeParser::LemonTask;
use SBuild::TargetResource;

#  Ctor
#
#  Usage: newRecord([$mask])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]lem$' if(! defined($mask));
	my $this = SMakeParser::ResolverRecord->newRecord($mask);
	bless $this, $class;
}

sub getResources {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $cres = SBuild::TargetResource->newResource($resource->getPurename . ".c");
	my $hres = SBuild::TargetResource->newResource($resource->getPurename . ".h");
	return ($cres, $hres);
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
	my ($cres, $hres) = $this->getResources($resource);
	$map->appendResource($cres);
	$map->appendResource($hres);
	
	# -- specify resource dependencies
	$map->appendDependency($cres->getID, $resource->getID);
	$map->appendDependency($hres->getID, $resource->getID);
	
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
	my ($cres, $hres) = $this->getResources($resource);
	#   Usage: newTask($name, $resource, \@target, \@source, \@deps)
	
	my $lemtask = SMakeParser::LemonTask->newTask(
							$resource->getFilename, $resource, 
							[$cres, $hres], [$resource], []);
	$assembler->appendTask("compile", $lemtask);
	
	# -- files to clean
	$assembler->addClean($cres);
	$assembler->addClean($hres);

	# -- add project dependency to force compilation of the utility before
	#    current project
	$assembler->addProjectDependency($assembler->getProject->getName, 
	                                 $assembler->getPhase->getFirstStage,,
	                                 "lemon", "binpostlink");
	
	return $lemtask;
}

return 1;
