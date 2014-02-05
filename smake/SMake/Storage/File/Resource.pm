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
# Usage: new($repository, $storage, $basepath, $prefix, $name)
#    repository ... a repository which the resource belongs to
#    storage ...... owning file storage
#    basepath ..... path of the artifact
#    name ......... name of the resource (as a relative path based on the artifact)
#    type ......... type of the resource (for example "src")
#    task ......... task which generates the resource
sub new {
  my ($class, $repository, $storage, $basepath, $name, $type, $task) = @_;
  my $this = bless(SMake::Model::Resource->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{name} = $name;
  $this->{path} = $basepath->joinPaths($name);
  $this->{type} = $type;
  $this->{task} = $task;
  return $this;
}

# Destroy the object (break cycles in references as the Perl uses reference counters)
#
# Usage: destroy()
sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{task} = undef;
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

sub getTask {
  my ($this) = @_;
  return $this->{task};
}

sub getStage {
  my ($this) = @_;
  return $this->{task}->getStage();
}

return 1;