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

# OTimer profile - usage of the shared timers
package SMakeParser::OTimerProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SMakeParser::ProjectAssembler;

#  Usage: newCompileProfile([\@modules...])
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("otimer");
	$this->{modules} = $_[0];
	if(! defined($this->{modules})) {
		$this->{modules} = ["manager"];
	}
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

	# -- basic otimer libraries
	my @liblist = (
			"avlonglong.lib",
			"avtimespec.lib",
			"otimer.lib", 
			"ondrart_datearith.lib", 
			"ondrart_log2.lib");
	my @mgrlibs = (
			"a3timeclient.lib",
			"avcrc32.lib",
			"ondrart_dynreg.lib",
			"ondrart_global.lib",
			"otimerextcli.lib", 
			"otimermgr.lib");
	my $mgrlink = 0;
	# -- modules
	foreach my $module (@{$this->{modules}}) {
		if($module eq "fbar2") {
			push @liblist, "otimerfbar2.lib", "fbar2.lib";
			$mgrlink = 1;
		}
		elsif($module eq "photon") {
			push @liblist, "otimerph.lib";
			$mgrlink = 1;
		}
		elsif($module eq "disablephoton") {
			push @liblist, "otimerphdisable.lib";
			$mgrlink = 1;
		}
		elsif($module eq "manager") {
			$mgrlink = 1;
		}
	}
	push @liblist, @mgrlibs if($mgrlink);

	$assembler->addLink(\@liblist);
}

return 1;
