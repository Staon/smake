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

# Rename a file task
package SBuild::RenameTask;

use SBuild::Task;
use File::Copy;

@ISA = qw(SBuild::Task);

#  Ctor
#
#  Usage: newTask($name, $resource, $source, $target)
sub newTask {
	my $class = shift;
	my $this = SBuild::Task->newTask($_[0], $_[1]);
	$this->{source} = $_[2];
	$this->{target} = $_[3];
	bless $this, $class;
}

#  Run the compilation
#    Usage: processTask(profile, reporter)
#    Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];

	move($this->{source}->getFullname($profile), $this->{target}->getFullname($profile));
	return 1;
}

return 1;
