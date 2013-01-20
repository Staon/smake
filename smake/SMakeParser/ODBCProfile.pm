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

# ODBC compilation profile
package SMakeParser::ODBCProfile;

use SBuild::CompileProfile;
use SBuild::Option;
use SMakeParser::ProfileUtils;

@ISA= qw(SBuild::CompileProfile);

#  Ctor
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("odbc");
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
#  Return: Updated value
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	
}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];

#	$assembler->removeLink(["aodbc.lib", "qnxodbc.lib", "avesoapodbc.lib", 
#	                        "aodbc_asoap.lib", "dbwatch_cli.lib"]);
	$assembler->addLink(["avesoapodbc.lib", "dbwatch_cli.lib", "aodbc.lib"]);
	$assembler->addForceLink(["qnxodbc.lib", "aodbc_asoap.lib"]);
	$assembler->addSysLink(["dblib", "odbc", "socket_s"]);
	
	# -- other linking (GSoap libraries)
	$assembler->addLink(["gsoap2++.lib", "gsoap2++env.lib", "avsoapclient.lib", 
	                     "ovarparser.lib", "aodbc_avedbacc.lib"]);
}

return 1;
