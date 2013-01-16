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

#  File resolver record of a test header
package SMakeParser::TestRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SMakeParser::TestTask;

#  Ctor
#
#  Usage: newRecord()
sub newRecord {
	my $class = $_[0];
	my $this = SMakeParser::ResolverRecord->newRecord('[.]h$');
	$this->{count} = 0;
	bless $this, $class;
}

sub getCXXResource {
	my $this = $_[0];
	my $resource = $_[1];
	return SBuild::TargetResource->newResource($resource->getPurename . ".otest.cc");
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
	
	# -- create .cc resource
	my $ccresource = $this->getCXXResource($resource);
	$map->appendResource($ccresource);
	$map->appendDependency($ccresource->getID, $resource->getID);
	
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

	# -- create test task
	my $ccresource = $this->getCXXResource($resource);
	my $testtask = SMakeParser::TestTask->newTask(
							$resource->getFilename, $resource,
							[$ccresource],
							[$resource],
							[], ++ $this->{count});
	$assembler->appendTask('compile', $testtask);
	$assembler->addClean($ccresource);
	
	return $testtask;
}

return 1;
