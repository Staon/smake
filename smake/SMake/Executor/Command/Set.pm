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

# Set of command nodes (unique command names)
package SMake::Executor::Command::Set;

use SMake::Executor::Command::Node;

@ISA = qw(SMake::Executor::Command::Node);

# Create new set node
#
# Usage: new($name)
sub new {
  my ($class, $name) = @_;
  my $this = bless(SMake::Executor::Command::Node->new(), $class);
  $this->{name} = $name;
  $this->{children} = {};
  return $this;
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

# Add or rewrite a child node
#
# Usage: putChild($child)
sub putChild {
  my ($this, $child) = @_;
  $this->{children}->{$child->getName()} = $child;
}

# Clear all children
sub clearSet {
  my ($this) = @_;
  $this->{children} = {};
}

# Get child of a name
#
# Usage: getChild($name)
# Returns: the child or undef
sub getChild {
  my ($this, $name) = @_;
  return $this->{children}->{$name};
}

# Get list of children nodes
sub getChildren {
  return values(%{$this->{children}});
}

return 1;
