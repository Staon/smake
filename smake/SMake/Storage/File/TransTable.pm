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
# Usage: new($base)
#    base .... base hash table
sub new {
  my ($class, $base) = @_;
  return bless({
    base => $base,
    inserted => {},
    deleted => {},
  }, $class);
}

# Insert new item
#
# Usage: insert($key, $value)
sub insert {
  my ($this, $key, $value) = @_;
  delete $this->{deleted}->{$key};
  $this->{inserted}->{$key} = $value;
}

# Remove an item
#
# Usage: remove($key)
# Returns: the value
sub remove {
  my ($this, $key) = @_;
  my $value = delete $this->{inserted}->{$key};
  $this->{deleted}->{$key} = 1;
  return $value;
}

# Get an item
#
# Usage: get($key)
# Returns: the value or undef
sub get {
  my ($this, $key) = @_;
  
  # -- deleted item
  return undef if(exists $this->{deleted}->{$key});
  
  # -- inserted item
  my $value = $this->{inserted}->{$key};
  return $value if(defined($value));
  
  # -- not changed item
  return $this->{base}->{$key};
}

# Commit changes
#
# Usage: commit($delfunc, $insfunc)
#    delfunc .... a functor which is called for each deleted item
#    insfunc .... a functor which is called for each inserted item
sub commit {
  my ($this, $delfunc, $insfunc) = @_;

  # -- deleted items  
  foreach my $item (keys %{$this->{deleted}}) {
    &$delfunc($item);
    delete ${$this->{base}}{$item};
  }
  
  # -- inserted items
  foreach my $item (keys %{$this->{inserted}}) {
    &$insfunc($item, $this->{inserted}->{$item});
    $this->{base}->{$item} = $this->{inserted}->{$item};
  }
}

return 1;
