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

# Command option
package SMake::Executor::Command::Option;

use SMake::Executor::Command::Node;

@ISA = qw(SMake::Executor::Command::Node);

# Create new option node
#
# Usage: new($value)
sub new {
  my ($class, $value) = @_;
  my $this = bless(SMake::Executor::Command::Node->new(), $class);
  $this->{value} = $value;
  return $this;
}

sub getName {
  my ($this) = @_;
  return $this->{value} . "";
}

sub getValue {
  my ($this) = @_;
  return $this->{value};
}

sub getSystemArgument {
  my ($this, $context, $wd, $mangler) = @_;
  return $this->{value};
}

return 1;
