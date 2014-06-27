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

use SMake::Model::Project;
use SMake::Storage::File::Project;
use SMake::Storage::File::TransTable;

# Create new transaction state
#
# Usage: new($storage)
sub new {
  my ($class, $storage) = @_;
  return bless({
    storage => $storage,
    projects => SMake::Storage::File::TransTable->new(
        sub { return $storage->loadProject($_[1], $_[0]); },
        sub { $storage->storeProject($_[2], $_[0], $_[1]); },
        sub { $storage->deleteProject($_[1], $_[0]); }),
  }, $class);
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
  my $item = $this->{projects}->get($prj->getKey(), $repository);
  if(defined($item)) {
    die "project '" . $name . "' already exists!";
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
      SMake::Model::Project::createKey($name), $repository);
}

# Commit the transaction
#
# Usage: commit($repository)
sub commit {
  my ($this, $repository) = @_;

  # -- commit and store data
  my $storage = $this->{storage};
  $this->{projects}->commit($repository);
}

return 1;
