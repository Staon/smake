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

# Node of a graph of dependencies
package SMake::Utils::TopOrderNode;

# Create new node
#
# Usage: new($object)
sub new {
  my ($class, $object) = @_;
  return bless([
    $object,
    [],  # -- children
    [],  # -- parents
    0,   # -- color (0 idle, 1 open, 2 closed)
    0,   # -- input degree
  ], $class);
}

# Get stored object
sub getObject {
  my ($this) = @_;
  return $this->[0];
}

# Get color
#
# Usage: getColor()
# Returns: "idle", "opened", "closed"
sub getColor {
  my ($this) = @_;
  if($this->[3] == 0) {
    return "idle";
  }
  elsif($this->[3] == 1) {
    return "opened";
  }
  elsif($this->[3] == 2) {
    return "closed";
  }
  else {
    die "invalid color";
  }
}

# Set color
#
# Usage: setColor($color)
sub setColor {
  my ($this, $color) = @_;
  if($color eq "idle") {
    $this->[3] = 0;
  }
  elsif($color eq "opened") {
    $this->[3] = 1;
  }
  elsif($color eq "closed") {
    $this->[3] = 2;
  }
  else {
    die "invalid color";
  }
}

# Append a child
sub appendChild {
  my ($this, $child) = @_;
  push @{$this->[1]}, $child;
}

# Revert dependency edges
sub revertEdges {
  my ($this) = @_;
  foreach my $child (@{$this->[1]}) {
    push @{$child->[2]}, $this;
    ++$this->[4];
  }
  $this->[1] = undef;  # -- it's not needed anymore
}

# Get input degree
sub getDegree {
  my ($this) = @_;
  return $this->[4];
}

# Finish the node
sub finish {
  my ($this, $keyfce, $queue) = @_;
  
  # -- iterate parents
  foreach my $parent (@{$this->[2]}) {
    --$parent->[4];
    $queue->update(&$keyfce($parent->getObject()), $parent->[4]);
  }
  $this->[2] = undef;
}

return 1;