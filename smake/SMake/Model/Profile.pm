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

# Generic profile model object
package SMake::Model::Profile;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Profile::Profile;
use SMake::Utils::Abstract;

# Create new profile object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get profile's dump string
sub getDumpString {
  SMake::Utils::Abstract::dieAbstract();
}

# Create profile object according to the stored dump
#
# Usage: createProfile()
# Returns: the profile object
sub createProfile {
  my ($this) = @_;
  
  my $profile = SMake::Profile::Profile::ressurect(
      $this->getDumpString());
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Profile {\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "dump: " . $this->getDumpString() . "\n";
  
  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
