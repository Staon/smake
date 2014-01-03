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

# File project storage
package SMake::Storage::File::Storage;

use SMake::Storage::Storage;

@ISA = qw(SMake::Storage::Storage);

use SMake::Storage::File::Transaction;

# Create new file storage
#
# Usage: new($path)
#    path .... file system location (a directory) of the storage
sub new {
  my ($class, $path) = @_;
  my $this = bless(SMake::Storage::Storage->new(), $class);
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{projects} = {};
  return $this;
}

sub destroyStorage {
  # -- nothing to do
}

# Open storage transaction
#
# Usage: openTransaction($repository)
# Exception: it can die when an error occurs
sub openTransaction {
  my ($this, $repository) = @_;
  $this->{transaction} = SMake::Storage::File::Transaction->new($this);
}

# Commit currently opened transaction
#
# Usage: commitTransaction($repository)
# Exception: it dies if an error occurs
sub commitTransaction {
  my ($this, $repository) = @_;
  if(defined($this->{transaction})) {
    # -- commit changes
    $this->{transaction}->commit();
    # -- compose new description list
    my $descrlist = {};
    foreach my $prj (values($this->{projects})) {
      $prj->updateDescriptionList($descrlist);
    }
  }
}

# Create new description object
#
# Usage: createDescription($repository, $path, $mark)
#    repository ... owning repository
#    path ......... logical path of the description file
#    mark ......... decider's mark of the description file
sub createDescription {
  my ($this, $repository, $path, $mark) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->createDescription($repository, $path, $mark);
}

# Create new project object
#
# Usage: createProject($repository, $name, $path)
#    repository ... owning repository
#    name ......... name of the project
#    path ......... logical path of the project
sub createProject {
  my ($this, $repository, $name, $path) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->createProject($repository, $name, $path);
}

return 1;
