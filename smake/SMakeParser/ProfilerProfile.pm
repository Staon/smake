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

#  Profiler profile
#
#  This compilation profile switches on options to compile
#  debug info.
package SMakeParser::ProfilerProfile;

use SBuild::CompileProfile;
use SBuild::Option;

@ISA= qw(SBuild::CompileProfile);

#  Ctor
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("profiler");
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

	if($variable eq "CFLAGS" or $variable eq "CXXFLAGS" or $variable eq "LDFLAGS") {
		# -- remove all previously defined options which set debug flags
		$optionlist->removeOptions("debug");
		# -- append new option flag
		$optionlist->appendOption(SBuild::Option->newOption("debug", "-g1"));
	}
}

return 1;
