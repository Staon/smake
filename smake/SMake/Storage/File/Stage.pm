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

# Implementation of the stage object for the file storage
package SMake::Storage::File::Stage;

use SMake::Model::Stage;

@ISA = qw(SMake::Model::Stage);

# Create new stage object
#
# Usage: new($repository, $artifact, $name)
sub new {
  my ($class, $repository, $artifact, $name) = @_;
  my $this = bless(SMake::Model::Stage->new(), $class);
  $this->{repository} = $repository;
  $this->{artifact} = $artifact;
  $this->{name} = $name;
  return $this;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getKey {
  my ($this) = @_;
  return $this->getName();
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

return 1;
