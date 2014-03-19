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

# Group of command nodes
package SMake::Executor::Command::Group;

use SMake::Executor::Command::Node;

@ISA = qw(SMake::Executor::Command::Node);

# Create new command group
#
# Usage: new($name)
sub new {
  my ($class, $name) = @_;
  my $this = bless(SMake::Executor::Command::Node->new());
  $this->{name} = $name;
  $this->{children} = [];
  
  return $this;
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

# Append a child node at the end of the group
#
# Usage: appendChild($child)
sub appendChild {
  my ($this, $child) = @_;
  push @{$this->{children}}, $child;
}

# Prepend a child node at the beginning of the group
#
# Usage: prependChild($child)
sub prependChild {
  my ($this, $child) = @_;
  unshift @{$this->{children}}, $child;
}

# Remove all children nodes
sub clearGroup {
  my ($this) = @_;
  $this->{children} = [];
}

# Get child of a name
#
# Usage: getChild($name)
# Returns: the child node or undef
sub getChild {
  my ($this, $name) = @_;
  foreach my $child (@{$this->{children}}) {
    if($child->getName() eq $name) {
      return $child;
    }
  }
  return undef;
}

return 1;
