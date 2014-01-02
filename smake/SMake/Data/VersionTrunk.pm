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

# Identifier of the trunk version
package SMake::Data::VersionTrunk;

use SMake::Data::Version;

@ISA = qw(SMake::Data::Version);

# Create new trunk version identifier
sub new {
  my ($class) = @_;
  return bless(SMake::Data::Version->new(), $class);
}

sub isLessTyped {
  return 0; # -- two trunk objects are the smae
}

sub printableString {
  return "trunk";
}

return 1;
