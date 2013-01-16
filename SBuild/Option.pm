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

#  One profile option
package SBuild::Option;

#  Ctor
#
#  Usage: newOption($name, $value)
sub newOption {
	my $class = $_[0];
	my $this = [$_[1], $_[2]];  # -- to keep memory low
	bless $this, $class;
}

#  Get option name
sub getName {
	my $this = $_[0];
	return $this->[0];
}

#  Compose profile value
#
#  Usage: composeValue($origvalue)
#  Return: new modified value
sub composeValue {
	my $this = $_[0];
	my $value = $_[1];
	my $myvalue = $this->[1];
	$value = $value . " " . $myvalue if(defined($myvalue));
	return $value;
}

return 1;
