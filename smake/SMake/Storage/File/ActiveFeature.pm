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

# Record of an active feature
package SMake::Storage::File::ActiveFeature;

use SMake::Model::Object;

@ISA = qw(SMake::Model::ActiveFeature);

use SMake::Utils::Abstract;
use SMake::Utils::Print;

# Create new feature object
#
# Usage: new($repository, $storage, $artifact, $name)
sub new {
  my ($class, $repository, $storage, $artifact, $name) = @_;

  my $this = bless(SMake::Model::ActiveFeature->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{artifact} = $artifact;
  $this->{name} = $name;
  
  return $this;
}

# Update attributes of the object
#
# Usage: update()
sub update {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{artifact} = undef;
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
