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

# Tool chain object. The tool chain is a configuration of used
# build system (compilers, code generators, etc.)
package SMake::ToolChain::ToolChain;

# Create new empty tool chain
#
# Usage: new($parent)
#    parent .... parent tool chain (can be undef)
#    mangler ... name mangler
sub new {
  my ($class, $parent, $mangler) = @_;
  return bless({
  	parent => $parent,
    constructors => {},
    mangler => $mangler,
  }, $class);
}

# Register an artifact creator
#
# Usage: registerConstructor($type, $constructor)
#    type .......... type of the artifact
#    constructor ... the constructor object
sub registerConstructor {
  my ($this, $type, $constructor) = @_;
  $this->{constructors}->{$type} = $constructor;
}

# Get an artifact constructor
#
# Usage: getConstructor($type)
# Returns: the constructor or undef
sub getConstructor {
  my ($this, $type) = @_;
  
  my $ctor = $this->{constructors}->{$type};
  return $ctor if(defined($ctor));
  
  # -- chain with the parent
  if(defined($this->{parent})) {
    return $this->{parent}->getConstructor($type);
  }
  
  return undef;
}

# Get name mangler
#
# Usage: getMangler()
# Returns: the mangler
sub getMangler() {
  my ($this) = @_;
  return $this->{mangler};
}

return 1;
