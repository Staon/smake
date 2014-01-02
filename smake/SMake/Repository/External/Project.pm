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

# Implementation of the project object for the external storage
package SMake::Repository::External::Project;

use SMake::Model::Project;

@ISA = qw(SMake::Model::Project);

use SMake::Repository::External::Artifact;
use SMake::Repository::External::Description;

# Create new project object
#
# Usage: new($repository, $name, $path)
#    repository .. the smake repository
#    name ........ name of the project
#    path ........ canonical path where the project is located at
sub new {
  my ($class, $repository, $name, $path) = @_;
  my $this = bless(SMake::Model::Project->new($repository), $class);
  $this->{name} = $name;
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{artifacts} = {};
  return $this;
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getVersion {
  my ($this) = @_;
  return $this->getRepository()->getVersion();
}

sub getVariant {
  my ($this) = @_;
  return $this->getRepository()->getVariant();
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getPhysicalPath {
  my ($this) = @_;
  return $this->{path};
}

sub attachDescription {
  my ($this, $description) = @_;
  $this->{descriptions}->{$description->getPath()} = $description;
}

sub createArtifact {
  my ($this, $name, $type, $args) = @_;
  
  my $artifact = SMake::Repository::External::Artifact->new(
      $this->getRepository(), $this, $name, $type, $args);
  $this->{artifacts}->{$name} = $artifact;
  return $artifact;
}

return 1;
