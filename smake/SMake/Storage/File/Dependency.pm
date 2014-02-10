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

# Implementation of the dependency object for the file storage
package SMake::Storage::File::Dependency;

use SMake::Model::Dependency;

@ISA = qw(SMake::Model::Dependency);

# Create new dependency object
#
# Usage: new($repository, $storage, $artifact, $deptype, $depprj, $departifact)
#    repository ........ repository
#    storage ........... owner storage
#    artifact .......... owner of the dependency
#    deptype ........... type of the dependency
#    depprj ............ name of the dependency project
#    departifact ....... name of the dependency artifact
#    depmain ........... type of the dependency main resource (undef for the default)
sub new {
  my ($class, $repository, $storage, $artifact, $deptype, $depprj, $departifact, $depmain) = @_;
  my $this = bless(SMake::Model::Dependency->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{artifact} = $artifact;
  $this->{deptype} = $deptype;
  $this->{depprj} = $depprj;
  $this->{departifact} = $departifact;
  $this->{depmain} = $depmain;
  
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{artifact} = undef;
}

sub getDependencyType {
  my ($this) = @_;
  return $this->{deptype};
}

sub getDependencyProject {
  my ($this) = @_;
  return $this->{depprj};
}

sub getDependencyArtifact {
  my ($this) = @_;
  return $this->{departifact};
}

sub getDependencyMainResource {
  my ($this) = @_;
  return $this->{depmain};
}

return 1;
