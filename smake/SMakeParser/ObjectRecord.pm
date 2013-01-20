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

#  A resolver record to handle raw object files (.o)
package SMakeParser::ObjectRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

#  Ctor
#
#  Usage: newResolverRecord([$mask])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]o$' if(! defined($mask));
	my $this = SMakeParser::ResolverRecord->newRecord($mask);
	bless $this, $class;
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

	# -- dependency on the main task
	$map->appendDependency($assembler->getMainResource, $resource->getID);
	
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

	$objname = $resource->getPurename . $profile->getToolChain->getObjectExtension;
	$objres = $resource->createFileResource($objname);
	my $task = SBuild::CheckFileTask->newTask($resource->getPurename, $resource, $objres);
	$assembler->addObject($objres);
	if(! $resource->isSourceResource) {
		$assembler->addClean($objres);
	}
	
	return $task;	
}

return 1;
 
