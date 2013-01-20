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

#  Debug profile
#
#  This compilation profile switches on options to compile
#  debug info.
package SMakeParser::DebugProfile;

use SBuild::CompileProfile;
use SBuild::Option;

@ISA= qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile($level)
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile->newCompileProfile("debug");
	$this->{level} = $_[1];
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
	
	my $tool;
	$tool = "c" if($variable eq "CFLAGS");
	$tool = "cxx" if($variable eq "CXXFLAGS");
	$tool = "link" if($variable eq "LDFLAGS");
	if(defined($tool)) {
		# -- remove colliding options
		$optionlist->removeOptions("debug");
		# -- construct new switch
		my $switch = $profile->getToolChain->getDebugOption($tool, $this->{level});
		if($switch ne "") {
			$optionlist->appendOption(SBuild::Option->newOption("debug", $switch));
		}
	}
}

return 1;
