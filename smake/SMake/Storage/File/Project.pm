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

# Implementation of the project object for the file storage
package SMake::Storage::File::Project;

use SMake::Model::Project;

@ISA = qw(SMake::Model::Project);

use SMake::Storage::File::Artifact;

# Create new project object
#
# Usage: new($repository, $storage, $name, $path)
#    repository .. the smake repository
#    storage ..... owning file storage
#    name ........ name of the project
#    path ........ logical project path
sub new {
  my ($class, $repository, $storage, $name, $path) = @_;
  my $this = bless(SMake::Model::Project->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{name} = $name;
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{artifacts} = {};
  return $this;
}

# Destroy the object (break cycles in references as the Perl uses reference counters)
#
# Usage: destroy()
sub destroy {
  my ($this) = @_;
  $this->{repository} = undef;
  $this->{storage} = undef;
  foreach my $artifact (@{$this->{artifacts}}) {
    $artifact->destroy();
  }
}

# Create key from attributes (static method)
#
# Usage: createKey($name)
sub createKey {
  my ($name) = @_;
  return $name;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getKey {
  my ($this) = @_;
  return createKey($this->{name});
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub attachDescription {
  my ($this, $description) = @_;
  $this->{descriptions}->{$description->getKey()} = 1;
  $description->addProject($this);
}

sub createArtifact {
  my ($this, $path, $name, $type, $args) = @_;
  
  my $artifact = SMake::Storage::File::Artifact->new(
      $this->getRepository(), $this->{storage}, $this, $path, $name, $type, $args);
  $this->{artifacts}->{$artifact->getKey()} = $artifact;
  return $artifact;
}

# Usage: getArtifact($name)
# Returns: the artifact or undef
sub getArtifact {
  my ($this, $name) = @_;
  return $this->{artifacts}->{$name};
}

return 1;