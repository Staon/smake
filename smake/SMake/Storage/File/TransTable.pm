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

# Transactional hash table
package SMake::Storage::File::TransTable;

# Create new table
#
# Usage: new($getfce, $insertfce, $deletefce, $lockfce)
sub new {
  my ($class, $getfce, $insertfce, $deletefce, $lockfce) = @_;
  return bless({
    base => $base,
    inserted => {},
    deleted => {},
    getfce => $getfce,
    insertfce => $insertfce,
    deletefce => $deletefce,
    lockfce => $lockfce,
  }, $class);
}

# Insert new item
#
# Usage: insert($key, $value)
sub insert {
  my ($this, $key, $value) = @_;
  delete $this->{deleted}->{$key};
  $this->{inserted}->{$key} = $value;
  &{$this->{lockfce}}($value, 1);
}

# Remove an item
#
# Usage: remove($key)
# Returns: the value
sub remove {
  my ($this, $key) = @_;
  
  my $value = delete $this->{inserted}->{$key};
  if(defined($value)) {
    &{$this->{lockfce}}($value, 0);
  }
  $this->{deleted}->{$key} = 1;
  return $value;
}

# Get an item
#
# Usage: get($key, ...)
# Returns: the value or undef
sub get {
  my ($this, $key) = splice(@_, 0, 2);
  
  # -- deleted item
  return undef if(exists $this->{deleted}->{$key});
  
  # -- inserted item
  my $value = $this->{inserted}->{$key};
  return $value if(defined($value));
  
  # -- not changed item
  $value = &{$this->{getfce}}($key, @_);
  if(defined($value)) {
    $this->{inserted}->{$key} = $value;
    &{$this->{lockfce}}($value, 1);
  }
  return $value;
}

# Commit changes
#
# Usage: commit(...)
sub commit {
  my $this = shift;

  # -- deleted items  
  foreach my $item (keys %{$this->{deleted}}) {
    &{$this->{deletefce}}($item, @_);
  }
  
  # -- inserted items
  foreach my $item (keys %{$this->{inserted}}) {
  	&{$this->{lockfce}}($this->{inserted}->{$item}, 0);
    &{$this->{insertfce}}($item, $this->{inserted}->{$item}, @_);
  }
}

return 1;
