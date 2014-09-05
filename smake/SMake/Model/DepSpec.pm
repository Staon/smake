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

# Generic dependency specification (specification of a feature)
package SMake::Model::DepSpec;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new feature object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Update attributes of the object
#
# Usage: update()
sub update {
  SMake::Utils::Abstract::dieAbstract();
}

# Create key tuple (static)
#
# Usage: createKeyTuple($spec)
sub createKeyTuple {
  return [$_[0]];
}

# Create a string key of the artifact (static)
#
# Usage: createKey($spec)
sub createKey {
  return $_[0];
}

sub getKeyTuple {
  my ($this) = @_;
  return createKeyTuple($this->getSpec());
}

sub getKey {
  my ($this) = @_;
  return createKey($this->getSpec());
}

# Get dependency specification
sub getSpec {
  SMake::Utils::Abstract::dieAbstract();
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "DepSpec(" . $this->getSpec() . ")";
}

return 1;
