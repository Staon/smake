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

# Generic command node
package SMake::Executor::Command::Node;

use SMake::Utils::Abstract;
use SMake::Utils::Utils;

# Create new command node
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Get node name
#
# Usage: getName()
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get node value
#
# Usage: getValue();
sub getValue {
  SMake::Utils::Abstract::dieAbstract();
}

# Get value of the node as a system argument
#
# Usage: getSystemArgument($context, $wd, $mangler)
#    context ...... executor context
#    wd ........... task's working directory (absolute filesystem path). It can be
#                   null => full resource path is used.
#    mangler ...... resource name mangler description. It can be null => name is
#                   not mangled.
# Returns: the argument string
sub getSystemArgument {
  SMake::Utils::Abstract::dieAbstract();
}

# Get value of the node as a system argument escaped for usage as a shell argument
#
# Usage: getSystemArgument($context, $wd, $mangler)
#    context ...... executor context
#    wd ........... task's working directory (absolute filesystem path). It can be
#                   null => full resource path is used.
#    mangler ...... resource name mangler description. It can be null => name is
#                   not mangled.
# Returns: the argument string
sub getShellArgument {
  my ($this, $context, $wd, $mangler) = @_;
  return quotemeta($this->getSystemArgument($context, $wd, $mangler));
}

# Get node at specified address
#
# Usage: getNode($context, $subsystem, $address)
#    context ..... parser/executor context
#    subsystem ... logging subsystem
#    address ..... address of the node (an SMake::Data::Path object)
# Return: the node or undef
sub getNode {
  my ($this, $context, $subsystem, $address) = @_;

  # -- get the value node
  my $len = $address->getSize();
  my $value = $this;
  foreach my $i (0 .. ($len - 1)) {
    my $part = $address->getPart($i);
    $value = $value->getChild($part);
    return undef if(!defined($value));
  }
  return $value;
}

return 1;
