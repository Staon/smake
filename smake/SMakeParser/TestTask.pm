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

#  Create OTest module
package SMakeParser::TestTask;

use SBuild::CompileTask;

@ISA = qw(SBuild::CompileTask);

use SMakeParser::ProfileUtils;

# Ctor
#   Usage: newTask($name, $resource, \@target, \@source, \@deps, $count)
sub newTask {
	$class = $_[0];
	$this = SBuild::CompileTask->newTask($_[1], $_[2], $_[3], $_[4], $_[5]);
	$this->{count} = $_[6];
	bless $this, $class;
}

#  Get taks command
#
#  Usage: getTaskCommand($profile, $reporter, \@targets, \@sources, $options)
#  Return: Command string
sub getTaskCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $targets = $_[3];
	my $sources = $_[4];
	my $options = $_[5];
	
	my $target = $targets->[0]->getFullname($profile);
	my $source = $sources->[0]->getFullname($profile);
	my $count = $this->{count};
	
	# -- get path to the otest utility
	my $verutil = SMakeParser::ProfileUtils::getFilePath($profile, "otest", "otest");

	return "$verutil -o $target $source $count";
}

return 1;
