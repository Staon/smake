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

#  ODBC library to connect to the Sybase database running on QNX
package SMakeParser::SybaseODBCProfile;

use SBuild::CompileProfile;
use SBuild::Option;
use File::Spec;

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
	
	my $makedir = $ENV{'MAKEDIR'};
	if($variable eq "LDFLAGS") {
		# -- find path to the ODBC libraries
		my $qnxpath = SMakeParser::ProfileUtils::getFilePath($profile, "qnxodbc.lib", "qnxodbc.lib");
		
		# -- append new option flags
		$optionlist->removeOptions("odbc");
		$optionlist->appendOption(SBuild::Option->newOption("odbc", "-ldblib -lodbc \"-Wl DISABLE 1038 FILE ${qnxpath}\" -ldbwatch_cli -laodbc")); 
	}
}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];

	# -- remove libraries of conflicting profiles
	$assembler->removeLink(["avesoapodbc.lib", "aodbc_asoap.lib"]);
	# -- add libraries
	$assembler->addLink(["dbwatch_cli.lib", "aodbc.lib"]);
	$assembler->addForceLink(["qnxodbc.lib"]);
	$assembler->addSysLink(["dblib", "odbc"]);
	
	# -- other linking (GSoap libraries)
	$assembler->addLink(["ovarparser.lib", "aodbc_avedbacc.lib"]);
}

return 1;
