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
#    roots ........ list of root objects
sub new {
  my ($class, $keyfce, $childrenfce, $roots) = @_;
  my $this = bless({
    keyfce => $keyfce,
    childrenfce => $childrenfce,
    order => [],
  }, $class);
  $this->compute($roots);
  return $this;
}

sub createMixin {
  my ($object) = @_;
  return [$object, 0, 0]; # [object, color (0 idle, 1 open, 2 closed), depth]
}

# Compute the order
#
# Usage: compute(\@roots)
#    roots ..... list of root objects
sub compute {
  my ($this, $roots) = @_;

  {
    # -- prepare DFS
    my @stack = ();
    my %touched = ();
    foreach my $root (@$roots) {
      push @stack, createMixin($root);
      $touched{&{$this->{keyfce}}($root)} = 1;
    }
  
    # -- run DFS
    while(@stack) {
      my $mixin = $stack[$#stack];
      if($mixin->[1] == 1) { # -- opened node
        # -- close the node
        $mixin->[1] = 2; # -- closed
        pop @stack;
        
        # insert into the list of objects
        unshift @{$this->{order}}, $mixin; 
      }
      elsif($mixin->[1] == 0) { # -- idle
        # -- open the node
        $mixin->[1] = 1;  # -- opened
      
        # -- iterate children
        my @children = &{$this->{childrenfce}}($mixin->[0]);
        foreach my $child (@children) {
          my $key = &{$this->{keyfce}}($child);
          if(!defined($touched{$key})) {
            push @stack, createMixin($child);
            $touched{$key} = 1;
          }
        }
      }
      else {
        die "invalid node state";
      }
    }
  }
  
  # TODO: compute depths
}

return 1;
