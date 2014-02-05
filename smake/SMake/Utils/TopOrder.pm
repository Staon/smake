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
    order => [],
  }, $class);
  return $this;
}

sub createMixin {
  my ($object) = @_;
  return [$object, [], 0, 0]; # [object, children, color (0 idle, 1 open, 2 closed), depth]
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
    my %touched = ();
    foreach my $root (@$roots) {
      my $mixin = createMixin($root);
      push @stack, $mixin;
      $touched{&{$this->{keyfce}}($root)} = $mixin;
    }
  
    # -- run DFS
    while(@stack) {
      my $mixin = $stack[$#stack];
      
      if($mixin->[2] == 1) { # -- opened node
        # -- close the node
        $mixin->[2] = 2; # -- closed
        pop @stack;
        
        # insert into the list of objects
        unshift @{$this->{order}}, $mixin; 
      }
      elsif($mixin->[2] == 0) { # -- idle
        # -- open the node
        $mixin->[2] = 1;  # -- opened
      
        # -- iterate children
        my $children = &{$this->{childrenfce}}($mixin->[0]);
        foreach my $child (@$children) {
          my $key = &{$this->{keyfce}}($child);
          if(!defined($touched{$key})) {
          	my $childmixin = createMixin($child);
            push @stack, $childmixin;
            $touched{$key} = $childmixin;
            push @{$mixin->[1]}, $childmixin;
          }
          else {
          	my $childmixin = $touched{$key};
          	if($childmixin->[2] == 1) {
          	  # -- cycled dependency, create DFS stack to report the cycle
          	  my $retval = [];
          	  foreach my $m (@stack) {
          	    push @$retval, $m->[0];
          	  }
          	  return (0, $retval);
          	}
            push @{$mixin->[1]}, $childmixin;
          }
        }
      }
      else {
        die "invalid node state";
      }
    }
  }

  # -- compute maximal depths from roots
  {
    foreach my $mixin (@{$this->{order}}) {
      my $depth = $mixin->[3] + 1;
      foreach my $child (@{$mixin->[1]}) {
        if($child->[3] < $depth) {
          $child->[3] = $depth;
        }
      }
      $mixin->[1] = undef; # -- memory optimization, the list is not needed anymore
    }
  }
  
  # -- sort the list to get elements in the same depth in one group
  my @sorted = sort { $b->[3] <=> $a->[3] } @{$this->{order}};
  $this->{order} = \@sorted;
  
  return (1);
}

sub printList {
  my ($this) = @_;

  my $first = 1;  
  foreach my $mixin (@{$this->{order}}) {
    if($first) {
      $first = 0;
    }
    else {
      print " ";
    }
    print "[" . $mixin->[3] . ": " . &{$this->{keyfce}}($mixin->[0]) . "]";
  }
}

return 1;
