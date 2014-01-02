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

# Version of the stable source line
package SMake::Data::VersionStable;

use SMake::Data::Version;

@ISA = qw(SMake::Data::Version);

my %CYCLE_TABLE = (
    'a' => 0,
    'b' => 1,
    'rc' => 2,
    '' => 3,
);

# Create new version object
#
# Usage: new($major, $minor, $cycle, $patch)
#    major .... major version number
#    minor .... minor version number
#    cycle .... release cycle ('a' -> alpha, 'b' -> beta, 'rc' -> release candidate, '' -> release)
#    patch .... patch level
sub new {
  my ($class, $major, $minor, $cycle, $patch) = @_;
  my $this = bless(SMake::Data::Version->new(), $class);
  $this->{major} = $major;
  $this->{minor} = $minor;
  $this->{cycle} = $cycle;
  $this->{patch} = $patch;
  
  die "invalid release cycle '$cycle'" if(!defined($CYCLE_TABLE{$cycle}));
  
  return $this;
}

sub isLessTyped {
  my ($this, $version) = @_;
  return 1 if($this->{major} < $version->{major});
  if($this->{major} == $version->{major}) {
    return 1 if($this->{minor} < $version->{minor});
    if($this->{minor} == $version->{minor}) {
      my ($l, $r) = ($CYCLE_TABLE{$this->{cycle}}, $CYCLE_TABLE{$version->{cycle}});
      return 1 if($l < $r);
      if($l == $r) {
        return $this->{patch} < $version->{patch};
      }
    }
  }
  
  return 0;
}

sub printableString {
  my ($this) = @_;
  return $this->{major} . "." . $this->{minor} . "." . $this->{cycle} . $this->{patch};
}

return 1;
