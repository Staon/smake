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

# Updateable dependency object
package SMake::Update::Dependency;

# Create new dependency object
#
# Usage: new($context, $artifact, $depkind, $deptype, $depprj, $departifact, $maintype)
#    context ...... parser context
#    artifact ..... parent artifact object
#    depkind ...... dependency kind
#    deptype ...... dependency type
#    depprj ....... dependency project
#    departifact .. dependency artifact
#    maintype ..... type of the main resource (can be null for default)
sub new {
  my ($class, $context, $artifact) = splice(@_, 0, 3);
  my $this = bless({}, $class);
  
  my $dep = $artifact->getObject()->getDependency(@_);
  if(!defined($dep)) {
    $dep = $artifact->getObject()->createDependency(@_);
  }
  $this->{artifact} = $artifact;
  $this->{dependency} = $dep;
  
  return $this;
}

# Update data of the object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;
  
  $this->{artifact} = undef;
  $this->{dependency} = undef;
}

# Get the model object
sub getObject {
  my ($this) = @_;
  return $this->{dependency};
}

# Get a string which can be used as a hash key
sub getKeyTuple {
  my ($this) = @_;
  return $this->{dependency}->getKeyTuple();
}

# Get a string which can be used as a hash key
sub getKey {
  my ($this) = @_;
  return $this->{dependency}->getKey();
}

# Get type of the dependency
sub getDependencyType {
  my ($this) = @_;
  return $this->{dependency}->getDependencyType();
}

# Get a name of the project
sub getDependencyProject {
  my ($this) = @_;
  return $this->{dependency}->getDependencyProject();
}

# Get name of the artifact
sub getDependencyArtifact {
  my ($this) = @_;
  return $this->{dependency}->getDependencyArtifact();
}

# Get type of the references main resource
#
# Usage: name of the type or undef if the default main resource should be used
sub getDependencyMainResource {
  my ($this) = @_;
  return $this->{dependency}->getDependencyMainResource();
}

return 1;
