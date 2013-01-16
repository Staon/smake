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

#  List of named compile profiles
package SBuild::NamedProfiles;

#  Ctor
sub newNamedProfiles {
	my $class = $_[0];
	my $this = {
		list => {}
	};
	bless $this, $class;
}

#  Register new profile
#
#  Usage: appendNamedProfile($name, $module [, @arguments])
sub appendNamedProfile {
	my $this = shift;
	my $name = shift;
	my $module = shift;
	my $arguments = [@_];
	
	$this->{list}->{$name} = [$module, $arguments];
}

#  Get named profile
#
#  Usage: getNamedProfile($name, args)
#  Return: The profile or undef
sub getNamedProfile {
	my $this = shift;
	my $name = shift;
	
	my $record = $this->{list}->{$name};
	if(defined($record)) {
		return $record->[0]->newCompileProfile(@{$record->[1]}, @_);
	}
	else {
		return undef;
	}
}

return 1;
