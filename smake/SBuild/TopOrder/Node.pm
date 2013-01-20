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

package SBuild::TopOrder::Node;

# Ctor
#   $1 ... a user data
sub newNode {
	my $class = shift;
	my $this = [
		[],           # -- list of dependencies
		$_[0],        # -- user data
		"fresh"       # -- DFS state
	];
	bless $this, $class;
}

# Get stored user data
sub getUserData {
	my $this = shift;
	return $this->[1];
}

# Append a dependency
#   $1 ... ID of target node
sub addDependency {
	my $this = shift;
	push @{$this->[0]}, $_[0];
}

# Get dependency list
sub getDependencyList {
	my $this = shift;
	return $this->[0];
}

# Init node DFS state
sub initDFSState {
	my $this = shift;
	$this->[2] = "fresh";
}

# Set DFS state
sub setDFSState {
	my $this = shift;
	$this->[2] = $_[0];
}

#  Get node DFS state
sub getDFSState {
	my $this = shift;
	return $this->[2];
}

sub printNode {
	my $this = shift;
	print "Dependencies:";
	print " $_" foreach (@{$this->[0]});
	print "\n";
}
return 1;
