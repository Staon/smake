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

#  Generic compilation profile
package SBuild::CompileProfile;

#  Ctor
#
#  Usage: newCompileProfile($name)
sub newCompileProfile {
	my $class = shift;
	my $this = {
		name => $_[0]
	};
	bless $this, $class;
}

#  Get profile name
sub getName {
	my $this = shift;
	return $this->{name};
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile, $reporter)
sub getOptions {
	die "It's not possible to invoke pure virtual method CompileProfile::getOptions!\n";
}

#  Extend the resource map of current project
#
#  Usage: extendMap($map, $assembler, $profile)
sub extendMap {
	# -- it does nothing by default
}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	# -- it does nothing by default
}

#  Get flag if a feature is active
#
#  Usage: isFeatureActive($feature_name, \$active_flag)
sub isFeatureActive {
	# -- do nothing by default
}

return 1;
