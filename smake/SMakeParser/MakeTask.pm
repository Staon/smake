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

#  Makefile task
#
#  This task only runs the make utility with a target
package SMakeParser::MakeTask;

use SBuild::CommandTask;

@ISA = qw(SBuild::CommandTask);

#  Ctor
#
#    Usage: newTask($name, $resource, $target [, $mkilechck])
sub newTask {
	my $class = $_[0];
	my $this = SBuild::CommandTask->newTask($_[1], $_[2]);
	$this->{target} = $_[3];
	$this->{mkfilechck} = $_[4];
	bless $this, $class;
}

#  Get task command
#  This is a pure virtual method!
#
#  Usage: getCommand($profile, $reporter, $project)
#  Return: Command string
sub getCommand {
	my $this = $_[0];
	my $target = $this->{target};
	
	if($this->{mkfilechck}) {
		if(-f "makefile" || -f "Makefile") {
			return "make $target";
		}		
		else {
			return "echo \"No makefile. It's not an error, the makefile should be generated during compilation stages.\"";
		}
	}
	else {
		return "make $target";
	}
}

return 1;
