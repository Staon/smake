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

# Version parser
package SMake::Parser::Version;

use SMake::Data::VersionTrunk;
use SMake::Data::VersionStable;

# Create new version parser
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Parse a version string
#
# Usage: parse($string)
# Returns: the version object or undef, if the string is not valid
sub parse {
  my ($this, $string) = @_;
  
  if($string =~ /^trunk$/) {
    return SMake::Data::VersionTrunk->new();
  }
  
  if($string =~ /^([\d]+)[.]([\d]+)[.](a|b|rc)?([\d]+)$/) {
    return SMake::Data::VersionStable->new($1, $2, defined($3)?$3:'', $4);
  }

  return undef;  
}

return 1;
