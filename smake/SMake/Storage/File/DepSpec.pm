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

# Implementation of the feature object for the file storage
package SMake::Storage::File::DepSpec;

use SMake::Model::DepSpec;

@ISA = qw(SMake::Model::DepSpec);

# Create new dependency specification
#
# Usage: new($repository, $storage, $feature, $type, $spec)
#    repository .... a repository which the artifact belongs to
#    storage ....... owning file storage
#    feature ....... the feature object which the spec belongs to
#    type .......... dependency type
#    spec .......... the specification
sub new {
  my ($class, $repository, $storage, $feature, $type, $spec) = @_;
  
  my $this = bless(SMake::Model::DepSpec->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{feature} = $feature;
  $this->{type} = $type;
  $this->{spec} = $spec;
  
  return $this;
}

# Destroy the object
sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{feature} = undef;
}

sub update {
  my ($this) = @_; 
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getType {
  my ($this) = @_;
  return $this->{type};
}

sub getSpec {
  my ($this) = @_;
  return $this->{spec};
}

return 1;
