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

# Empty request. The request is used as an initial request value
package SMake::Data::RequestEmpty;

use SMake::Data::Request;

@ISA = qw(SMake::Data::Request);

# Create new empty request
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Data::Request->new(), $class);
}

sub appendRequest {
  my ($this, $request) = @_;
  return $request;
}

sub appendToContainer {
  # nothing to do
}

sub mergeRequestInternal {
  my ($this, $request);
  return (1, $request);
}

sub printableString {
  return "Empty";
}

return 1;
