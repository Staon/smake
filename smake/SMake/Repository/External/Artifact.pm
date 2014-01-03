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

# Implementation of the Artifact object for the External repository
package SMake::Repository::External::Artifact;

use SMake::Model::Artifact;

@ISA = qw(SMake::Model::Artifact);

use SMake::Repository::External::Resource;
use SMake::Repository::External::Stage;

# Create new artifact object
#
# Usage: new($repository, $project, $path, $name, $type, \%args)
#    repository .... a repository which the artifact belongs to
#    project ....... a project which the artifact belongs to
#    path .......... canonical location (directory) of the artifact
#    name .......... name of the artifact
#    type .......... type of the artifact
#    args .......... optional artifact's arguments
sub new {
  my ($class, $repository, $project, $path, $name, $type, $args) = @_;
  my $this = bless(SMake::Model::Artifact->new(), $class);
  $this->{repository} = $repository;
  $this->{project} = $project;
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{name} = $name;
  $this->{type} = $type;
  $this->{args} = $args;
  $this->{resources} = {};
  $this->{stages} = {};
  return $this;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getProject {
  my ($this) = @_;
  return $this->{project};
}

sub attachDescription {
  my ($this, $description) = @_;
  $this->{descriptions}->{$description->getPath()->hashKey()} = $description;
}

sub createResource {
  my ($this, $prefix, $name) = @_;
  my $resource = SMake::Repository::External::Resource->new(
      $this->{repository}, $this->{path}, $prefix, $name);
  $this->{resources}->{$resource->getName()} = $resource;
  return $resource;
}

sub createStage {
  my ($this, $name) = @_;
  my $stage = $this->{stages}->{$name};
  if(!defined($stage)) {
    $stage = SMake::Repository::External::Stage->new(
        $this->{repository}, $this, $name);
    $this->{stages}->{$name} = $stage;
  }
  return $stage;
}

return 1;
