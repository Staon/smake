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

#  Setting of makeversion's arguments
package SMakeParser::VersionProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;

#  Ctor
#
#  Usage: newCompileProfile($status, ...)
#
#  clean:
#     $revision, $reppath, $major, $minor, $patch [, $srcline]
#  muddy:
#     $reppath, $major, $minor, $patch
#  dirty:
#     nothing
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("version");
	
	my $status = lc($_[0]);
	my $args;
	if($status =~ m/^clean/) {
		$status =~ s/^clean-//;
		$args = "--status=clean --revision=$_[1] --reppath='$_[2]' --major=$_[3] --minor=$_[4] --patch=$_[5]";
		$args = "$args --srcline=$_[6]" if(defined($_[6]));
		$args = "$args --rstage=$status" if($status);
	}
	elsif($status eq "muddy") {
		$args = "--status=muddy --reppath='$_[1]' --major=$_[2] --minor=$_[3] --patch=$_[4]";
	}
	else {
		$args = "";
	}
	$this->{args} = $args;
	
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

	if($variable eq "MAKEVERSION_ARGS") {
		$optionlist->removeOptions("makeversion");
		$optionlist->appendOption(SBuild::Option->newOption("makeversion", $this->{args}));
	}	
}

return 1;
