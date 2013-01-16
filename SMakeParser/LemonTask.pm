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

#  Lemon parser
package SMakeParser::LemonTask;

use SBuild::CompileTask;

@ISA = qw(SBuild::CompileTask);

use SMakeParser::ProfileUtils;

#  Ctor
#
#   Usage: newTask($name, $resource, \@target, \@source, \@deps)
sub newTask {
	$class = shift;
	$this = SBuild::CompileTask->newTask(@_);
	bless $this, $class;
}

#  Get task command
#
#  Usage: getTaskCommand(profile, $reporter, \@targets, \@sources, $options)
#  Return: Command string
sub getTaskCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $targets = $_[3];
	my $sources = $_[4];
	my $options = $_[5];
	
	my $lempath = SMakeParser::ProfileUtils::getFilePath($profile, "lemon", "lemon");
	return "$lempath " . $sources->[0]->getFullname($profile);
}

return 1;
