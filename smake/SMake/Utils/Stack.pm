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

# Helper stack class
package SMake::Utils::Stack;

# Create new stack
#
# Usage: new($name)
#    name .... name of the stack (used in diagnostic messages)
sub new {
  my ($class, $name) = @_;
  return bless([$name, []], $class);
}

# Check if the stack is empty
sub isEmpty {
  my ($this) = @_;
  return $#{$this->[1]} < 0;
}

# Push an object
#
# Usage: pushObject($object)
sub pushObject {
  my ($this, $object) = @_;
  push @{$this->[1]}, $object;
}

# Pop an object
#
# Usage: popObject()
sub popObject {
  my ($this) = @_;
  my $object = pop @{$this->[1]};
  if(!defined($object)) {
    die "empty $this->[0] stack!";
  }
}

# Get the object at the top
#
# Usage: topObject()
sub topObject {
  my ($this) = @_;
  my $object = $this->[1]->[$#{$this->[1]}];
  if(!defined($object)) {
    die "empty $this->[0] stack!";
  }
  return $object;
}

return 1;
