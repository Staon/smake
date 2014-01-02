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

# Parser of version request
package SMake::Parser::VersionRequest;

use SMake::Data::RequestVersion;
use SMake::Parser::Version;

# Create new parser
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    version_parser => SMake::Parser::Version->new(),
  }, $class);
}

# Parser a version request
#
# Usage: parse($string)
# Returns: parsed request or undef, if the string is not valid
sub parse {
  my ($this, $string) = @_;
  
  if($string =~ /^[\s]*(<=|>=|=)[\s]*([^\s]+)[\s]*$/) {
    my $operator = $1;
    my $version = $this->{version_parser}->parse($2);
    if($operator eq "<=") {
      return SMake::Data::RequestVersion->new(undef, $version);
    }
    elsif($operator eq ">=") {
      return SMake::Data::RequestVersion->new($version, undef);
    }
    else {
      return SMake::Data::RequestVersion->new($version, $version);
    }
  }

  return undef;  
}

return 1;
