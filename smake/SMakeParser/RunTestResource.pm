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

#  Pseudo resource to generate a test runner
package SMakeParser::RunTestResource;

use SMakeParser::PseudoResource;

@ISA = qw(SMakeParser::PseudoResource);

use SBuild::TargetResource;
use SMakeParser::RunTestTask;

#  Ctor
#
#  newResource($runner)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::PseudoResource->newResource("runtest:" . $_[1]->getFilename);
	$this->{runner} = $_[1];
	bless $this, $class;
}

sub getCCResource {
	my $this = $_[0];
	return SBuild::TargetResource->newResource($this->{runner}->getPurename . ".cc");
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	my $res = $this->getCCResource;
	$map->appendResource($res);
	$map->appendDependency($res->getID, $this->getID);
	
	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	my $res = $this->getCCResource;
	my $task = SMakeParser::RunTestTask->newTask($res->getFilename, $this, [$res], [], []);
	$assembler->appendTask("compile", $task);
	$assembler->addClean($res);
	
	return $task;
} 

return 1;
