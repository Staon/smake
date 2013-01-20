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

#  Cache of libraries of projects
package SBuild::LibCache;

#  Ctor
sub newLibCache {
	my $class = $_[0];
	my $this = {
		cache => {},
		missed => 0,
		passed => 0
	};
	bless $this, $class;
}

#  Check if a library is cached here
#
#  Usage: isCached($project)
sub isCached {
	my $this = $_[0];
	my $project = $_[1];
	if(defined($this->{cache}->{$project})) {
		++ $this->{passed};
		return 1;
	}
	else {
		++ $this->{missed};
		return 0;
	}
}

#  Get list of libraries
#
#  Usage: getListOfLibraries($project)
#  Return: \@list
sub getListOfLibraries {
	my $this = $_[0];
	my $project = $_[1];
	my $list = $this->{cache}->{$project};
	if(defined($list)) {
		return $list;
	}
	else {
		return [];
	}
}

#  Cache data
#
#  Usage: cacheData($project, \@liblist)
sub cacheData {
	my $this = $_[0];
	my $project = $_[1];
	my $liblist = $_[2];
	
	$this->{cache}->{$project} = $liblist;
}

sub printStats {
	my $this = $_[0];
	print "Missed: " . $this->{missed} . " Passed: " . $this->{passed} . "\n";
}

return 1;
