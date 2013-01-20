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

#  Change file mode tail resource
package SMakeParser::ChmodResource;

use SMakeParser::TailResource;

@ISA = qw(SMakeParser::TailResource);

use SBuild::ChmodTask;

#  Ctor
#
#  Usage: newResource($id, $srcresid, $mode)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::TailResource->newResource($_[1], $_[2]);
	$this->{mode} = $_[3];
	bless $this, $class;
}

#  Process a target resource (append the tail task to it)
#
#  Usage: processTailResource($map, $assembler, $profile, $reporter, $resource)
sub processTailResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];
	
	my $task = SBuild::ChmodTask->newTask($this->getID, $this, $resource, $this->{mode});
	$assembler->appendTask("postlink", $task);
	
	return $task;
} 

return 1;
