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

#  Generic task which depends on run of another task

package SBuild::DepTask;

use SBuild::Task;
use SBuild::Utils;

@ISA = qw(SBuild::Task);

#  Ctor
#
#  Usage: newTask($name, $resource, $mark | \@marks)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{marks} = SBuild::Utils::getArrayRef($_[3]);
	bless $this, $class;
}
 
#  Decide if the task should be run
#
#  Usage: shallBeRun($profile, $reporter, $project)
#  Return: True when the project shall be run
sub shallBeRun {
	my $this = $_[0];
	my $profile= $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	foreach my $mark (@{$this->{marks}}) {
		return 1 if($project->isTaskMarkActive($mark));
	}
	return 0;
}

return 1;
