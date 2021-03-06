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

# Generic variable profile
package SMake::Profile::VarProfile;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

# Create new variable profile
#
# Usage: new($name, $value)
sub new {
  my ($class, $name, $value) = @_;
  
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{name} = $name;
  $this->{value} = $value;
  return $this;
}

sub getVariable {
  my ($this, $context, $name) = @_;
  
  if($name eq $this->{name}) {
    return $this->{value};
  }
  else {
    return undef;
  }
}

return 1;
