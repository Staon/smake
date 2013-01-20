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

#  Use message task
package SMakeParser::UseTask;

use SBuild::DepCommandTask;

@ISA = qw(SBuild::DepCommandTask);

# Ctor
#   Usage: newTask($binres, $taskmark, $exeres, $useres, $cflag)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::DepCommandTask->newTask("usage:" . $_[1]->getFilename, $_[1], $_[2]);
	$this->{exeres} = $_[3];
	$this->{useres} = $_[4];
	$this->{cflag} = $_[5];
	bless $this, $class;
}

#  Get task command
#  This is a pure virtual method!
#
#  Usage: getCommand($profile, $reporter, $project)
#  Return: Command string
sub getCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $c = '';
	$c = '-c ' if($this->{cflag});	
	return "usemsg $c" . $this->{exeres}->getFullname($profile) . 
	       " " . $this->{useres}->getFullname($profile);
}

return 1;
