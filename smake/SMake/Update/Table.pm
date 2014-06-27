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

# Helper table which keeps info about newly created items and deleted items
package SMake::Update::Table;

# Create new table
#
# Usage: new($keyfce, \@keys)
#    keyfce ... a function which computes key from a tuple
#    keys ..... list of key tuples
sub new {
  my ($class, $keyfce, $keys) = @_;
  my $this = bless({}, $class);
  
  $this->{fce} = $keyfce;
  $this->{table} = {map {&$keyfce(@$_) => [$_, 0]} @$keys};
  $this->{changed} = 0;
  return $this;  
}

# Add an item
#
# Usage: addItem($item)
sub addItem {
  my ($this, $item) = @_;
  
  my $key = $item->getKey();
  my $record = $this->{table}->{$key};
  if(!defined($record)) {
    $this->{table}->{$key} = [$item->getKeyTuple(), $item];
    $this->{changed} = 1;
  }
  else {
    $record->[1] = $item;  
  }
}

# Get item identified by a string key
#
# Usage: getItemByKey($key)
# Returns: the item or undef
sub getItemByKey {
  my ($this, $key) = @_;
  
  my $record = $this->{table}->{$key};
  return (defined($record) && $record->[1])?$record->[1]:undef;
}

# Get item identifier by a key tuple
#
# Usage: getItemByTuple($tuple)
# Returns: the item or undef
sub getItemByTuple {
  my ($this, $tuple) = @_;
  return $this->getItemByKey(&{$this->{fce}}(@$tuple));
}

# Get list of items
#
# Usage: getItems()
# Returns: \@list
sub getItems {
  my ($this) = @_;
  return [grep {$_} (map {$_->[1]} values %{$this->{table}})];
}

# Update changed items
#
# Usage: update($context)
# Returns: (\@todelete, $changed)
#    todelete ..... list of key tuples to be deleted
#    changed ...... flag if the set of items has changed
sub update {
  my ($this, $context) = @_;
  
  my $todelete = [];
  my $changed = $this->{changed};
  foreach my $item (values %{$this->{table}}) {
    if($item->[1]) {
      $item->[1]->update($context);
    }
    else {
      push @$todelete, $item->[0];
      $changed = 1;
    }
  }

  $this->{table} = {};
  $this->{changed} = 0;
  
  return $todelete, $changed;
}

return 1;
