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

#  Change owner and group of a file
package SBuild::ChownTask;

use SBuild::CommandTask;

@ISA = qw(SBuild::CommandTask);

#  Ctor
#
#  Usage: newTask($name, $resource, $file, $user [, $group])
sub newTask {
	my $class = $_[0];
	my $this = SBuild::CommandTask->newTask($_[1], $_[2]);
	$this->{resource} = $_[3];
	$this->{user} = $_[4];
	$this->{group} = $_[5];
	bless $this, $class;
}

#  Get task command
#
#  Usage: getCommand($profile, $reporter, $project)
#  Return: Command string
sub getCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $group = $this->{group};
	if(defined($group)) {
		$group = "." . $group;
	}
	else {
		$group = "";
	}
	return "chown " . $this->{user} . $group . " " . $this->{resource}->getFullname($profile);
}

return 1;
