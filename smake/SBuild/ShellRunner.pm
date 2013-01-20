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

#  Shell command runner
#
#  This runner really runs commands
package SBuild::ShellRunner;

use SBuild::Runner;

@ISA = qw(SBuild::Runner);

use QNX4;

# Ctor
sub newRunner {
	my $class = shift;
	my $this = SBuild::Runner->newRunner;
	bless $this, $class;
}

#  Run a command
#
#  Usage: runCommand($command)
#  Return: (retflag, rettext) - retflag = OK/ERR
sub runCommand {
	my $command = $_[1];
	my $rettext = QNX4::backticks_keepalive("$command 2>&1", 15000, " ========= SMAKE HEARTBEAT ========= \n");
	return (! $?, $rettext);
}

#  Run a command but not catch its output
#  This is a pure virtual method!
#
#  Usage: runCommandConsole($command)
#  Return: $retflag (OK/ERR)
sub runCommandConsole {
	my $command = $_[1];
	system($command);
	return ! $?;
}

return 1;
