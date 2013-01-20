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

# Cleaning task
package SBuild::CleanTask;

use SBuild::CommandTask;

@ISA = qw(SBuild::CommandTask);

#  Ctor
#
#  Usage: newTask($name, $resource, \@file_list)
sub newTask {
	my $class = shift;
	my $this = SBuild::CommandTask->newTask($_[0], $_[1]);
	$this->{clean_list} = $_[2];
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

	# -- Get command to clean
	my $cleanlist = $this->convertToFileList($profile, $this->{clean_list});
	my $cf = $profile->getProfileStack->getOptions("CLEAN_FILES", $profile, $reporter);
	return $profile->getToolChain->getClean($cleanlist, "", $cf);
}

return 1;
