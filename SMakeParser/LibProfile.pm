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

# Generic library profile
#
# This profile keeps a list of linked projects and a list of system
# libraries.
package SMakeParser::LibProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;
use SMakeParser::ProjectAssembler;

#  Ctor
#
#  Usage: newCompileProfile(\@prjlist, \@syslist)
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("generic_lib_profile");
	$this->{prjlist} = $_[0];
	$this->{syslist} = $_[1];
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
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

	# -- append libraries to the linker composer
	$assembler->addLink($this->{prjlist});
	$assembler->addSysLink($this->{syslist});
}

return 1;
