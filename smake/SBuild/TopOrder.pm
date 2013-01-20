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

package SBuild::TopOrder;

use SBuild::TopOrder::Node;

# Top order sorter - ctor
sub newTopOrder {
	my $class = shift;
	my $this = {
		nodes => {}
	};
	bless $this, $class;
}

# Add a new node
#   $1 ... identifier of the node
#   $2 ... associated user data
sub addNode {
	my $this = shift;
	$this->{nodes}->{$_[0]} = SBuild::TopOrder::Node->newNode($_[1]); 
}

#  Check if a node exists
#
#  Usage: doesExist($id)
#  Return: True when it exists
sub doesExist {
	my $this = $_[0];
	my $id = $_[1];
	
	return defined($this->{nodes}->{$id});
}

# Add a new dependency
#   $1 ... source
#   $2 ... target
sub addDependency {
	my $this = shift;
	my $node = $this->{nodes}->{$_[0]};
	if(defined($node)) {
		$node->addDependency($_[1]);
	}
}

# Compute topological order
#
# Returns: list of topological ordered user data, or undef (it must be reverted)
sub computeOrder {
	my $this = shift;
	my @ret;
	my @nodekeys = keys(%{$this->{nodes}});
	
	# Compute initial in degrees
	my %ind;
	foreach my $node (@nodekeys) {
		my $deps = $this->{nodes}->{$node}->getDependencyList;
		++ $ind{$_} foreach (@{$deps});
	}

	# Work queue
	my @q;
	@q = grep { ! $ind{$_} } @nodekeys;

	# Loop
	while (@q) {
		my $id = pop @q;
		my $node = $this->{nodes}->{$id};
		my $deps = $node->getDependencyList;
		$ret[@ret] = $node->getUserData;
		
		foreach my $dep (@{$deps}) {
			push @q, $dep if (! --$ind{$dep});
		}
	}

	return @ret == @nodekeys ? (1, @ret) : (0, grep { $ind{$_} } @nodekeys);
}

sub privateDFS {
	my $this = $_[0];
	my $node = $_[1];
	my $order = $_[2];

	if($node->getDFSState eq "closed") { return 1; }
	if($node->getDFSState eq "opened") {
		# -- a cycle, to the list push cycled nodes
		$#{$order} = -1;
		push @$order, $node->getUserData;
#		$order = [$node->getUserData];
		return 0; 
	}
	
	$node->setDFSState("opened");

	# -- iterate all children
	my $deps = $node->getDependencyList;
	foreach $dep (@$deps) {
		my $depnode=$this->{nodes}->{$dep};
		if(! $this->privateDFS($depnode, $order)) {
			push @$order, $node->getUserData;
			return 0;
		}
	}
	
	# -- close the node
	$node->setDFSState("closed");
	$order->[@$order] = $node->getUserData;
	
	return 1;
}

# Compute topological order for specified stage
#
#  Usage: computeDeps(\@stages [, $filter])
sub computeDeps {
	my $this = $_[0];
	my $stages = $_[1];
	my $filter = $_[2];
	
	my @nodekeys = keys(%{$this->{nodes}});
	$filter = ".*" if(! defined($filter));
	
	
	# Initialize DFS states
	foreach my $key (@nodekeys) {
		my $node = $this->{nodes}->{$key};
		$node->initDFSState;
	}

	# Ordered list
	my @list = ();
	
	foreach my $stage (@$stages) {	
		# Grep root nodes
		my @roots = grep {
			my $prj = $_;
			my $st = $_;
			$prj =~ s/:[^:]*$//;
			$st =~ s/^[^:]*://;
			
			$st =~ /^$stage$/ and 
			$this->{nodes}->{$_}->getDFSState eq "fresh" and
			$prj =~ /$filter/
			 
		} @nodekeys;
	
	
		foreach $root (@roots) {
			my $node = $this->{nodes}->{$root};
			if(!$this->privateDFS($node, \@list)) {
				return (0, \@list);
			}
		}
	}
	
	return (1, \@list);
}

sub printList {
	my $this = shift;
	foreach my $key (keys(%{$this->{nodes}})) {
		print "Node: $key\n";
		my $node = $this->{nodes}->{$key};
		$node->printNode;
		print "\n";
	}
}

return 1;
