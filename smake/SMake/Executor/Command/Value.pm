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

# Named command value
package SMake::Executor::Command::Value;

use SMake::Executor::Command::Node;

@ISA = qw(SMake::Executor::Command::Node);

# Create new value node
#
# Usage: new($name, $value)
sub new {
  my ($class, $name, $value) = @_;
  my $this = bless(SMake::Executor::Command::Node->new(), $class);
  $this->{name} = $name;
  $this->{value} = $value;
  return $this;
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

# Get the value
sub getValue {
  my ($this) = @_;
  return $this->{value};
}

# Get value of the node as a system argument
#
# Usage: getValueArgument($context, $separator)
#    context ...... executor context
#    separator .... separator of name and value
# Returns: the argument string
sub getValueArgument {
  my ($this, $context, $separator) = @_;
  
  my $str = $this->{name};
  if(defined($this->{value})) {
    $str .= $separator;
    $str .= quotemeta($this->{value});
  }
  return $str;
}

return 1;
