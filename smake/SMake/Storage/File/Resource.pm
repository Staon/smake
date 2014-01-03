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

# Implementation of the resource object for the file storage
package SMake::Storage::File::Resource;

use SMake::Model::Resource;

@ISA = qw(SMake::Model::Resource);

# Create new resource
#
# Usage: new($repository, $basepath, $prefix, $name)
#    repository ... a repository which the resource belongs to
#    basepath ..... path of the artifact
#    prefix ....... a relative path based on the artifact
#    name ......... name of the resource (as a relative path based on the artifact)
#    type ......... type of the resource (for example "src")
sub new {
  my ($class, $repository, $basepath, $prefix, $name, $type) = @_;
  my $this = bless(SMake::Model::Resource->new(), $class);
  $this->{repository} = $repository;
  $this->{name} = $prefix->joinPaths($name);
  $this->{path} = $basepath->joinPaths($prefix, $name);
  $this->{type} = $type;
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
  return $this->{name}->asString();
}

sub getType {
  my ($this) = @_;
  return $this->{type};
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getRelativePath {
  my ($this) = @_;
  return $this->{name};
}

return 1;
