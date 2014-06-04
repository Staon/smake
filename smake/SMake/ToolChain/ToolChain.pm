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
# Usage: new($parent, $mangler, $builder, $translator)
#    parent ....... parent tool chain (can be undef)
#    mangler ...... resource name mangler
#    builder ...... builder od abstract commands
#    translator ... a translator of abstract commands to instruction objects
#                   (for example shell commands)
#    runner ....... a shell runner (a shell command executor)
#    scanner ...... source scanner (generator of external resources)
#    filter ....... filter of external resources
sub new {
  my ($class, $parent, $mangler, $builder, $translator, $runner, $scanner, $filter) = @_;
  return bless({
  	parent => $parent,
    constructors => {},
    mangler => $mangler,
    builder => $builder,
    translator => $translator,
    runner => $runner,
    scanner => $scanner,
    filter => $filter,
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

# Get command builder
#
# Usage: getBuilder();
# Returns: the builder
sub getBuilder {
  my ($this) = @_;
  return $this->{builder};
}

# Get command translator
sub getTranslator {
  my ($this) = @_;
  return $this->{translator};
}

# Get shell runner
sub getRunner {
  my ($this) = @_;
  return $this->{runner};
}

# Get source scanner
sub getScanner {
  my ($this) = @_;
  return $this->{scanner};
}

# Get the resource filter
sub getResourceFilter {
  my ($this) = @_;
  return $this->{filter};
}

return 1;
