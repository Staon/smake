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

# Free variant. This variant is used by the developer (external) repository.
# It means, that there is no special variant and shape of compiled projects
# depends only on configured compilation profiles.
package SMake::Data::VariantFree;

use SMake::Data::Variant;

@ISA = qw(SMake::Data::Variant);

# Create the variant identifier
sub new {
  my ($class) = @_;
  return bless(SMake::Data::Variant->new(), $class);
}

sub hashKey {
  return "free";
}

# Get a printable string representation
sub printString {
  return "<free>";
}

return 1;
