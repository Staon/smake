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

#  List of compilation profiles
package SBuild::ProfileList;

#  Ctor
sub newProfileList {
	my $class = shift;
	my $this = {
		profiles => []
	};
	bless $this, $class;
}

#  Append a new compilation profile
#
#  Usage: appendProfile($profile)
sub appendProfile {
	my $this = $_[0];
	my $profile = $_[1];
	push @{$this->{profiles}}, $profile;
}

#  Append a list of compilation profiles
#
#  Usage: appendProfiles($list)
sub appendProfiles {
	my $this = $_[0];
	my $list = $_[1];
	push @{$this->{profiles}}, @{$list->{profiles}};
}

#  Get a specified variable
#
#  Usage: getOptions($variable, $optionlist, $profile, $reporter)
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $prof = $_[3];
	my $reporter = $_[4];

	# -- iterate all stored profiles
	my $profiles = $this->{profiles};
	foreach my $profile (@$profiles) {
		$profile->getOptions($variable, $optionlist, $prof, $reporter);
	}
}

#  Extend the resource map by the profiles
#
#  Usage: extendMap($map, $assembler, $profile)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	
	# -- iterate all stored profiles
	my $profiles = $this->{profiles};
	$_->extendMap($map, $assembler, $profile) foreach (@$profiles);
}

#  Change project structure according to profiles
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	
	# -- iterate all stored profiles
	my $profiles = $this->{profiles};
	$_->changeProject($map, $assembler, $profile) foreach (@$profiles);
}

#  Check if a feature is active
#
#  Usage: isFeatureActive($feature_name, \$active_flag)
sub isFeatureActive {
	my $this = $_[0];
	my $name = $_[1];
	my $active_flag = $_[2];
	
	# -- iterate all stored profiles
	my $profiles = $this->{profiles};
	$_->isFeatureActive($name, $active_flag) foreach(@$profiles);
}

sub dumpList {
	my $this = $_[0];
	foreach my $prof (@{$this->{profiles}}) {
		print $prof->getName . ".";
	}
	print "\n";
}

return 1;
