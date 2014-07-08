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

# List of paths to be combined into a timestamp mark
package SMake::ToolChain::Decider::DeciderList;

# Create new list
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    paths => {},
  }, $class);
}

# Append paths into the list
#
# Usage: appendPaths($path*)
#    resource .... absolute physical path (in the filesystem meaning)
sub appendPaths {
  my $this = shift;
  foreach my $path (@_) {
    $this->{paths}->{$path->asString()} = $path;
  }
}

# Get ordered list of the paths
#
# Returns: \@list
sub getOrderedList {
  my ($this) = @_;
  
  return [map { $this->{paths}->{$_} } (sort {$a cmp $b} keys(%{$this->{paths}}))];
}

return 1;
