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

# State of project storage transaction
package SMake::Storage::File::Transaction;

use SMake::Storage::File::Description;
use SMake::Storage::File::Project;
use SMake::Storage::File::TransTable;

# Create new transaction state
#
# Usage: new($storage)
sub new {
  my ($class, $storage) = @_;
  return bless({
    storage => $storage,
    projects => SMake::Storage::File::TransTable->new($storage->{projects}),
    descriptions => SMake::Storage::File::TransTable->new($storage->{descriptions}),
  }, $class);
}

# Create new description object
#
# Usage: createDescription($repository, $parent, $path, $mark)
#    repository ... owning repository
#    parent ....... parent description object (it can be undef for root objects)
#    path ......... logical path of the description file
#    mark ......... decider's mark of the description file
sub createDescription {
  my ($this, $repository, $parent, $path, $mark) = @_;

  my $descr = SMake::Storage::File::Description->new(
      $repository, $this->{storage}, $parent, $path, $mark);
  my $item = $this->{descriptions}->get($descr->getKey());
  if(defined($item)) {
    die "description '" . $descr->getKey() . "' already exists!";
  }
  $this->{descriptions}->insert($descr->getKey(), $descr);
  
  return $descr;
}

# Get description object
#
# Usage: getDescription($repository, $path)
# Returns: the object or undef
sub getDescription {
  my ($this, $repository, $path) = @_;
  return $this->{descriptions}->get(
      SMake::Storage::File::Description::createKey($path));
}

# Get description object (identified by a key)
#
# Usage: getDescriptionKey($key)
sub getDescriptionKey {
  my ($this, $key) = @_;
  return $this->{descriptions}->get($key);
}

# Create new project object
#
# Usage: createProject($repository, $name, $path)
#    repository ... owning repository
#    name ......... name of the project
#    path ......... logical path of the project
sub createProject {
  my ($this, $repository, $name, $path) = @_;
  
  my $prj = SMake::Storage::File::Project->new(
      $repository, $this->{storage}, $name, $path);
  my $item = $this->{projects}->get($prj->getKey());
  if(defined($item)) {
    die "project '" . $prj->getKey() . "' already exists!";
  }
  $this->{projects}->insert($prj->getKey(), $prj);
  
  return $prj;
}

# Get project object
#
# Usage: getProject($repository, $name)
sub getProject {
  my ($this, $repository, $name) = @_;
  return $this->{projects}->get(
      SMake::Storage::File::Project::createKey($name));
}

# Commit the transaction
#
# Usage: commit($repository)
sub commit {
  my ($this, $repository) = @_;

  # -- commit and store data
  my $storage = $this->{storage};
  $this->{descriptions}->commit(sub { }, sub { });
  $this->{projects}->commit(
      sub { $storage->deleteProject($repository, $_[0]); },
      sub { $storage->storeProject($repository, $_[0], $_[1]); });
}

return 1;
