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

#  Stack of lists of compilation profiles
package SBuild::ProfileStack;

use SBuild::OptionList;

#  Ctor
sub newProfileStack {
	my $class = shift;
	my $this = {
		stack => []
	};
	bless $this, $class;
}

#  Push a new profile list
#
#  Usage: pushList($list)
sub pushList {
	my $this = $_[0];
	push @{$this->{stack}}, $_[1];
}

#  Pop a list 
sub popList {
	my $this = $_[0];
	pop @{$this->{stack}};
}

#  Get a specified variable
#
#  Usage: getOptions($variable, $prof, $reporter)
#  Return: updated value of the variable
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $prof = $_[2];
	my $reporter = $_[3];
	my $stack = $this->{stack};

	# -- create an option list
	my $optionlist = SBuild::OptionList->newOptionList;
	# -- fill the list
	foreach my $proflist (@$stack) {
		$proflist->getOptions($variable, $optionlist, $prof, $reporter);
	}
	# -- compose the value (and trim it)
	my $value = $optionlist->composeValue;
	$value =~ s/^\s*|\s*$//g;

	return $value;
}

#  Extend the resource map
#
#  Usage: extendMap($map, $assembler, $profile)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	
	# -- iterate profiles
	my $stack = $this->{stack};
	$_->extendMap($map, $assembler, $profile) foreach(@$stack);
}

#  Change project structure according to profiles
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	
	# -- iterate profiles
	my $stack = $this->{stack};
	$_->changeProject($map, $assembler, $profile) foreach(@$stack);
}

#  Check if a feature is active
#
#  Usage: isFeatureActive($name)
#  Return: true or false
sub isFeatureActive {
	my $this = $_[0];
	my $name = $_[1];

	# -- iterate profiles
	my $active = 0;
	foreach my $proflist (@{$this->{stack}}) {
		$proflist->isFeatureActive($name, \$active);
	}
	
	return $active;
}

sub dumpList {
	my $this = $_[0];
	my $i = 1;
	foreach my $prof (@{$this->{stack}}) {
		print "$i ";
		$prof->dumpList;
		++ $i;
	}
}

return 1;
