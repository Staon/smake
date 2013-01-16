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

#  Path to include files
package SBuild::IncludeProfile;

use SBuild::CompileProfile;
use SBuild::Option;
use SBuild::Utils;

@ISA = qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile(\@dirlist)
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile::->newCompileProfile("lib");
	$this->{dirlist} = [@{$_[1]}];
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
		foreach my $dir (reverse @{$this->{dirlist}}) {
			$dir = SBuild::Utils::parseProjectString($profile->getRepository, $dir);
			$optionlist->prependOption(
				SBuild::Option->newOption("", $profile->getToolChain->getIncDirOption($dir)));
		}
	}
}

return 1;
