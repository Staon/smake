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

# Generic identifier of a version
package SMake::Data::Version;

use SMake::Data::VersionOrder;
use SMake::Utils::Abstract;

# Create new version identifier
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Check if the version is less than a version
#
# Usage: isLess($version)
# Returns: true if the version is less than or equal the argument
sub isLess {
  my ($this, $version) = @_;
  
  my $left = $SMake::Data::VersionOrder::ORDER{ref($this)};
  die "invalid version type " . ref($this) if(!defined($left));
  my $right = $SMake::Data::VersionOrder::ORDER{ref($version)};
  die "invalid version type " . ref($version) if(!defined($right));
  
  if($left < $right) {
    return 1;
  }
  elsif($left == $right) {
    return $this->isLessTyped($version);
  }
  else {
    return 0;
  }
}

# Check the '<=' relation
#
# Usage: isLessOrEqual($version)
sub isLessOrEqual {
  my ($this, $version) = @_;
  return $this->isLess($version) && !$version->isLess($this);
}

# Check the '>' relation
#
# Usage: isGreater($version)
sub isGreater {
  my ($this, $version) = @_;
  return $version->isLess($this);
}

# Check the '>=' relation
#
# Usage: isGreaterOrEqual($version)
sub isGreaterOrEqual {
  my ($this, $version) = @_;
  return $version->isLess($this) && !$this->isLess($version);
}

# Check the '==' relation
#
# Usage: isEqual($version)
sub isEqual {
  my ($this, $version) = @_;
  return !$this->isLess($version) && !$version->isLess($this);
}

# Check the '!=' relation
#
# Usage: isNotEqual($version)
sub isNotEqual {
  my ($this, $version) = @_;
  return $this->isLess($version) || $version->isLess($this);
}

# Check if the version is less than a version. Types of the versions are the same.
#
# Usage: isLessTyped($version)
# Returns: true if the version is less than or equal the argument
sub isLessTyped {
  SMake::Utils::Abstract::dieAbstract();
}

# Compose a printable representation of the version
sub printableString {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
