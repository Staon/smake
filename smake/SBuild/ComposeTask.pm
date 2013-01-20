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

#  A task composed from several tasks
package SBuild::ComposeTask;

use SBuild::Task;

@ISA = qw(SBuild::Task);

#  Ctor
#
#  Usage: newTask($name, $resource, \@tasks)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{tasks} = $_[3];
	bless $this, $class;
}

# Default empty running method
#   Usage: processTask(profile, reporter, $project)
#   Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	my $tasks = $this->{tasks};
	foreach my $task (@$tasks) {
		return 0 if(! $task->runTask($profile, $reporter, $project));
	}
	
	return 1;
}

return 1;
