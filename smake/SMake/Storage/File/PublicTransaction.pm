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

# Transactional table of public resources
package SMake::Storage::File::PublicTransaction;

use SMake::Storage::File::TransTable;
use SMake::Utils::Tuple;

# Create new transaction object
#
# Usage: new($origin)
#    origin ..... origin table
sub new {
  my ($class, $origin) = @_;
  my $this = bless({}, $class);
  $this->{table} = SMake::Storage::File::TransTable->new(
      sub { return $origin->{table}->{$_[0]}; },
      sub { $origin->{table}->{$_[0]} = $_[1]; },
      sub { delete $origin->{table}->{$_[0]}; },
      sub { });
  return $this;
}

# Register a public resource
#
# Usage: registerResource($resource, $project)
#    resource ...... resource key tuple
#    project ....... project key tuple
sub registerResource {
  my ($this, $resource, $project) = @_;
  
  # -- get already existing or create new record
  my $record = $this->{table}->get(SMake::Model::Resource::createKey(@$resource));
  if(!defined($record)) {
    $record = [];
  }
  else {
    $record = [@$record];  # -- don't modify origin record
  }
  
  # -- append project
  push @$record, $project;
  $this->{table}->insert(SMake::Model::Resource::createKey(@$resource), $record);
}

# Unregister a public resource
#
# Usage: unregisterResource($resource, $project)
#    resource ...... resource key tuple
#    project ....... project key tuple
sub unregisterResource {
  my ($this, $resource, $project) = @_;

  # -- get existing record  
  my $record = $this->{table}->get(SMake::Model::Resource::createKey(@$resource));
  if(defined($record)) {
    # -- filter the project
  	$record = [grep { !SMake::Utils::Tuple::isEqual($_, $project) } @$record];
  	if($#$record < 0) {
  	  # -- no other projects, remove the whole record
  	  $this->{table}->remove(SMake::Model::Resource::createKey(@$resource));
  	}
  	else {
  	  # -- modified project record
      $this->{table}->insert(SMake::Model::Resource::createKey(@$resource), $record);
  	}
  }
}

# Search for public resource
#
# Usage: searchResource($resource)
#    resource .. resource key tuple
# Returns: \@list
#    list ...... list of project's key tuples or undef
sub searchResource {
  my ($this, $resource) = @_;
  
  my $key = SMake::Model::Resource::createKey(@$resource);
  my $record = $this->{table}->get($key);
  if(defined($record)) {
    return [@$record];
  }
  else {
    return undef;
  }
}

# Commit changes
#
# Usage: commit()
sub commit {
  my ($this) = @_;
  $this->{table}->commit();
}

return 1;
