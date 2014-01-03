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
# Usage: new($repository, $name, $path)
#    repository .. the smake repository
#    name ........ name of the project
#    path ........ logical project path
sub new {
  my ($class, $repository, $name, $path) = @_;
  my $this = bless(SMake::Model::Project->new(), $class);
  $this->{repository} = $repository;
  $this->{name} = $name;
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{artifacts} = {};
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

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub attachDescription {
  my ($this, $description) = @_;
  $this->{descriptions}->{$description->getKey()} = $description;
}

sub createArtifact {
  my ($this, $path, $name, $type, $args) = @_;
  
  my $artifact = SMake::Storage::File::Artifact->new(
      $this->getRepository(), $this, $path, $name, $type, $args);
  $this->{artifacts}->{$artifact->getKey()} = $artifact;
  return $artifact;
}

# Compose new description list
#
# This method is used to clean list of descriptions in the storage root
# after a transaction.
#
# Usage: updateDescriptionList(\%list)
sub updateDescriptionList {
  my ($this, $list) = @_;
  @$list{keys %{$this->{descriptions}}} = values %{$this->{descriptions}};
}

return 1;
