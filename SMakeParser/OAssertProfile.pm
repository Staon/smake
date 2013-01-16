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

# turning on/off of the oassert system
package SMakeParser::OAssertProfile;

use SBuild::CompileProfile;

@ISA = qw(SBuild::CompileProfile);

use SBuild::Option;

#  Ctor
#
#  Usage: newCompileProfile([$level])
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile->newCompileProfile("oassert");
	$this->{level} = $_[1];
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
#  Return: Updated value
sub getOptions {
	my $this = $_[0];
	my $var = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];

	if($var eq "CPPFLAGS" || $var eq "CXXCPPFLAGS") {
		$optionlist->removeOptions("oassert");
		$optionlist->appendOption(SBuild::Option->newOption(
				"oassert",
				"-DOASSERT_ACTIVE"));
		if(defined($this->{level})) {
			$optionlist->appendOption(SBuild::Option->newOption(
				"oassert",
				"-DOASSERT_LEVEL=" . ($this->{level} + 0)));
		}
	}	
}

#  Modify current project
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];

	# -- add library
	$assembler->addLink("ondrart_assert.lib");
}

return 1;
