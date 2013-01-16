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

#  Generic command runner

package SBuild::Runner;

#  Ctor
sub newRunner {
	my $class = shift;
	my $this = {};
	bless $this, $class;
}

#  Run a command
#  This is a pure virtual method!
#
#  Usage: runCommand($command)
#  Return: (retflag, rettext) - retflag = OK/ERR
sub runCommand {
	die "Pure virtual method Runner::runCommand cannot be invoked!\n";
}

#  Run a command but not catch its output
#  This is a pure virtual method!
#
#  Usage: runCommandConsole($command)
#  Return: $retflag (OK/ERR)
sub runCommandConsole {
	die "Pure virtual method Runner::runCommandConsole cannot be invoked!\n";
}

return 1;
