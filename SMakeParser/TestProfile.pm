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

# A compilation profile which is used to activate the "test" feature
#
# The Test directive (resource) adds it into the list of compilation
# profiles thus the the feature is implicitly on when a test is built.
package SMakeParser::TestProfile;

use SBuild::CompileProfile;

@ISA = qw(SBuild::CompileProfile);

#  Usage: newCompileProfile()
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("test");
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
sub getOptions {
	my ($this, $variable, $optionlist, $profile) = @_;
	
}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my ($this, $map, $assembler, $profile) = @_;

}

#  Get flag if a feature is active
#
#  Usage: isFeatureActive($feature_name, \$active_flag)
sub isFeatureActive {
	my ($this, $name, $flag) = @_;
	$$flag = 1 if($name eq "test");
}

return 1;
