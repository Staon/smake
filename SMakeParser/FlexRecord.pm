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

#  Flex resolver record
package SMakeParser::FlexRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::FlexTask;
use SBuild::TargetResource;

#  Ctor
#
#  Usage: newRecord([$mask [, $c_flag]])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]l$' if(! defined($mask));
	my $this = SMakeParser::ResolverRecord->newRecord($mask);
	$this->{c_flag} = $_[2];
	bless $this, $class;
}

sub getResources {
	my $this = $_[0];
	my $resource = $_[1];

	my $purename = $resource->getPurename;
	my $tgres;
	if($this->{c_flag}) {
		$tgres = SBuild::TargetResource->newResource($purename . ".l.c");
	}
	else {
		$tgres = SBuild::TargetResource->newResource($purename . ".l.cpp");
	}
	my $bisonres = SBuild::TargetResource->newResource($purename . ".tab.h");
	
	return ($tgres, $bisonres);
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
	(my $tgres, my $bisonres) = $this->getResources($resource);
	$map->appendResource($tgres);
	
	# -- specify resource dependencies
	$map->appendDependency($tgres->getID, $resource->getID);
	
	# -- this is a special dependency when flex is used with bison
	$map->appendDependency($resource->getID, $bisonres->getID);
	
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

	# -- create the flex task
	(my $tgres, my $bisonres) = $this->getResources($resource);
	my $flextask = SBuild::FlexTask->newTask(
						$resource->getFilename, $resource,
						[$tgres], [$resource], []);
	$assembler->appendTask("compile", $flextask);

	# -- files to clean
	$assembler->addClean($tgres);

	return $flextask;
}

return 1;
