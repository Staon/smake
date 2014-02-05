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

# Address of a stage
package SMake::Data::Address;

# Create new address
#
# Usage: new($project, $artifact, $stage)
sub new {
  my ($class, $project, $artifact, $stage) = @_;
  return bless({
    project => $project,
    artifact => $artifact,
    stage => $stage,
  }, $class);
}

# Get a string which can be used as a key
sub getKey {
  my ($this) = @_;
  return $this->{project} . "/" . $this->{artifact} . "/" . $this->{stage};
}

# Get project name
sub getProject {
  my ($this) = @_;
  return $this->{project};
}

# Get name of the artifact
sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

# Get name of the stage
sub getStage {
  my ($this) = @_;
  return $this->{stage};
}

# Compare two addresses for equality
sub isEqual {
  my ($this, $address) = @_;
  return ($this->{project} eq $address->{project})
      && ($this->{artifact} eq $address->{artifact})
      && ($this->{stage} eq $address->{stage});
}

# A helper statis function: print a list of addresses
#
# Usage: printAddressList(\@list)
sub printAddressList {
  my ($list) = @_;
  my $first = 1;
  foreach my $address (@$list) {
    if($first) {
      $first = 0;
    }
    else {
      print " ";
    }
    print $address->getKey();
  }
}

return 1;
