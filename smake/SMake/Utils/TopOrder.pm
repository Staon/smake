# Copyright (C) 2014 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is a free software: you can redistribute it and/or modify
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

# A helper object to compute topological order
package SMake::Utils::TopOrder;

use List::PriorityQueue;
use SMake::Utils::TopOrderNode;

# Create new object
#
# Usage: new(\&keyfce, \&childrenfce, \@roots)
#    keyfce ....... compute a hash table key for an object
#    childrenfce .. compute list of children of an object
sub new {
  my ($class, $keyfce, $childrenfce) = @_;
  my $this = bless({
    keyfce => $keyfce,
    childrenfce => $childrenfce,
    nodes => {},
  }, $class);
  return $this;
}

# Compute the order
#
# Usage: compute(\@roots)
#    roots ..... list of root objects
# Returns:
#    (true) ......... computation succesfully finished
#    (false, list) .. there is a cycle in the graph, the list contains
#                     current stack of the DFS
sub compute {
  my ($this, $roots) = @_;

  # -- computation of a topological order
  {
    # -- prepare DFS
    my @stack = ();
    foreach my $root (@$roots) {
      my $node = SMake::Utils::TopOrderNode->new($root);
      push @stack, $node;
      $this->{nodes}->{&{$this->{keyfce}}($root)} = $node;
    }
  
    # -- run DFS
    while(@stack) {
      my $node = $stack[$#stack];
      
      if($node->getColor() eq "opened") {
        # -- close the node
        $node->setColor("closed");
        pop @stack;
        
        # insert into the list of objects
        unshift @{$this->{order}}, $node; 
      }
      elsif($node->getColor() eq "idle") {
        # -- open the node
        $node->setColor("opened");
      
        # -- iterate children
        my $children = &{$this->{childrenfce}}($node->getObject());
        foreach my $child (@$children) {
          my $key = &{$this->{keyfce}}($child);
          if(!defined($this->{nodes}->{$key})) {
          	my $childnode = SMake::Utils::TopOrderNode->new($child);
          	$node->appendChild($childnode);
            push @stack, $childnode;
            $this->{nodes}->{$key} = $childnode;
          }
          else {
          	my $childnode = $this->{nodes}->{$key};
            $node->appendChild($childnode);
          	
          	# -- detect dependency cycle
          	if($childnode->getColor() eq "opened") {
              my $retval = [$childnode->getObject()];
              foreach my $n (@stack) {
                push @$retval, $n->getObject();
              }
              return (0, $retval);
          	}
          }
        }
      }
      else {
        die "invalid node state";
      }
    }
  }

  # -- revert edges to be prepared for leaf cutting
  foreach my $node (values(%{$this->{nodes}})) {
    $node->revertEdges();
  }
  
  # -- construct the priority queue
  $this->{queue} = List::PriorityQueue->new();
  foreach my $node (values(%{$this->{nodes}})) {
    $this->{queue}->insert(
        &{$this->{keyfce}}($node->getObject()), $node->getDegree());
  }
  
  return (1);
}

# Get list of all leaves
#
# Usage: getLeaves()
# Returns: \@list or undef, if the queue is empty
sub getLeaves {
  my ($this) = @_;

  # -- empty queue
  return undef if($this->{queue}->empty());

  # -- get list of top objects
  my $item = $this->{queue}->popPriority(0);
  my $list = [];
  while(defined($item)) {
    my $node = $this->{nodes}->{$item};
    push @$list, $node->getObject();
    
    $item = $this->{queue}->popPriority(0);
  }

  return $list;  
}

# Finish an object
#
# The method finishes an object. It means that dependencies are cleared and dependent
# objects can become leaves which can be got by the method getLeaves().
#
# Usage: finishObject($object)
sub finishObject {
  my ($this, $object) = @_;

  my $key = &{$this->{keyfce}}($object);  
  my $node = $this->{nodes}->{$key};
  $node->finish($this->{keyfce}, $this->{queue});
}

return 1;
