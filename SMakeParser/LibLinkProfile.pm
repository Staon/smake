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

#  Library link profile
package SMakeParser::LibLinkProfile;

use SBuild::CompileProfile;

@ISA = qw(SBuild::CompileProfile);

use SBuild::Option;
use SBuild::ProjectList;
use SMakeParser::LibRunner;

#  Ctor
#
#  Usage: newCompileProfile($linker_composer)
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile->newCompileProfile("liblink");
	$this->{linker_composer} = $_[1];
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile, $reporter)
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	if($variable eq "LDFLAGS") {
		$this->{linker_composer}->getLinkerOptions($optionlist, $profile, $reporter);
	}
}

return 1;
