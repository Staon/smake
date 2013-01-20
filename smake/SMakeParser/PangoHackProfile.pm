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

#  Pango hack profile
#
#  This profile links libraries needed for the hacked Arabic support
#  in Photon applications. In addition it defines preprocessor variable
#  AVECO_PANGO_HACK to turn on the hack during compilation.
package SMakeParser::PangoHackProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;

#  Ctor
#
#  Usage: newCompileProfile()
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("pango_hack");
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

	if($variable eq "CPPFLAGS" or $variable eq "CXXCPPFLAGS") {
		$optionlist->appendOption(SBuild::Option->newOption("pango_hack", "-DAVECO_PANGO_HACK"));
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
	$assembler->addLink([
	  "libiconv.lib",
	  "libexpat.a",
	  "tinyglib.lib",
	  "freetype2.lib",
	  "fontconfig2.lib",
	  "pango.lib",
	  "otk.lib",
	]);
}

return 1;
