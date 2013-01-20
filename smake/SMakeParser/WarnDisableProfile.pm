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

#  Warning disable
#
#  This profile switches off a compiler or linker warning (or other message)
package SMakeParser::WarnDisableProfile;

use SBuild::CompileProfile;
use SBuild::Option;

@ISA= qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile($msgnum)
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("warndisable");
	$this->{msgnum} = $_[0];
	$this->{msgnum} = 0 if(! defined($this->{msgnum}));
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
	
	# -- compiler warnings
	#    Although the documentation mentions the -wcd option, it doesn't work
	#    for me. So the profile can switch off only linker warnings
#	if(($variable eq "CFLAGS" or $variable eq "CXXFLAGS") and ($this->{msgnum} < 1000)) {
#		my $arg = "-wcd=" . $this -> {msgnum};
#		if($variable eq "CFLAGS") {
#			$arg = "'-Wc," . $arg . "'";
#		}
#		else {
#			$arg = "'-WC," . $arg . "'";
#		}
#		$optionlist->appendOption(SBuild::Option->newOption("", $arg));
#	}
	# -- linker warnings
	if($variable eq "LDFLAGS" and $this->{msgnum} >= 1000) {
		my $msgnum = $this->{msgnum} % 1000;
		$optionlist->appendOption(SBuild::Option->newOption("", "'-Wl DISABLE " . $msgnum . "'"));
	}
}

return 1;
