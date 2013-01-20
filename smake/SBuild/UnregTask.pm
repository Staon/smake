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

# Unregistering from a local repository
package SBuild::UnregTask;

use SBuild::Task;

@ISA = qw(SBuild::Task);

#  Ctor
#
#    Usage: newTask($taskname, $resource, $projectname)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{projectname} = $_[3];
	bless $this, $class;
}

#  Run the task
#    Usage: processTask(profile, reporter)
#    Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	# -- remove the project from the repository
	$profile->getRepository->cleanProject($this->{projectname});
	$reporter->reportRepositoryProjectUnreg($this->{projectname});
	
	return 1;
}

return 1;
