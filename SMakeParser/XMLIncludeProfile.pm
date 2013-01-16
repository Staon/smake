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

#  Path to headers of XML libraries
package SMakeParser::XMLIncludeProfile;

use SBuild::CompileProfile;
use SBuild::Option;
use File::Spec;

@ISA = qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile()
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile::->newCompileProfile("xmldir");
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
	
	if($variable eq "CPPFLAGS" or $variable eq "CXXCPPFLAGS") {
		# -- Expat library
		my $expat_dir = $profile->getRepository->getProjectPath("libexpat.a");
		if(defined($expat_dir)) {
			$expat_dir = File::Spec->catdir($expat_dir, "lib");
			$optionlist->appendOption(
				SBuild::Option->newOption("", $profile->getToolChain->getIncDirOption($expat_dir)));
		}
		
		# -- Parsifal library
		my $parsifal_dir = $profile->getRepository->getProjectPath("libparsifal.lib");
		if(defined($parsifal_dir)) {
			$parsifal_dir = File::Spec->catdir($parsifal_dir, "../include/libparsifal");
			$optionlist->appendOption(
				SBuild::Option->newOption("", $profile->getToolChain->getIncDirOption($parsifal_dir)));
		}
	}
}

return 1;
