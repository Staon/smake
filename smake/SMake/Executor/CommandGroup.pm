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
package SMake::Executor::CommandGroup;

use SMake::Executor::CommandNode;

@ISA = qw(SMake::Executor::CommandNode);

# Create new command group
#
# Usage: new($name)
sub new {
  my ($class, $name) = @_;
  my $this = bless(SMake::Executor::CommandNode->new());
  $this->{name} = $name;
  $this->{children} = {};
  
  return $this;
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub addChild {
	
}

return 1;
