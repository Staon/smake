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

#  List of profile options
package SBuild::OptionList;

#  Ctor
sub newOptionList {
	my $class = $_[0];
	my $this = {
		options => []
	};
	bless $this, $class;
}

#  Append a new option
#
#  Usage: appendOption($option)
sub appendOption {
	my $this = $_[0];
	my $option = $_[1];
	my $options = $this->{options};
	$options->[@$options] = $option;
} 

#  Prepend an option
#
#  Usage: prependOption($option)
sub prependOption {
	my $this = $_[0];
	my $option = $_[1];
	my $options = $this->{options};
	$this->{options} = [$option, @$options];
}

#  Remove all options with a name
#
#  Usage: removeOptions($name)
sub removeOptions {
	my $this = $_[0];
	my $name = $_[1];
	my $options = $this->{options};
	
	my @filtered = grep { $_->getName ne $name } @$options;
	$this->{options} = \@filtered;
}

#  Compose string value according to stored options
#
#  Usage: composeValue
#  Return: composed string value
sub composeValue {
	my $this = $_[0];
	my $options = $this->{options};
	my $value = "";   # -- initial empty value
	$value = $_->composeValue($value) foreach (@$options);
	return $value;
}

return 1;
