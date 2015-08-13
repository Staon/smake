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

# Cache of computed timestamp marks
package SMake::Executor::MarkCache::OrdinaryCache;

use SMake::Executor::MarkCache::MarkCache;

@ISA=qw(SMake::Executor::MarkCache::MarkCache);

# Create new cache object
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = SMake::Executor::MarkCache::MarkCache->new();
  $this->{cache} = {};
  return bless($this, $class);
}

sub insertMark {
  my ($this, $path, $mark) = @_;
  $this->{cache}->{$path->hashKey()} = $mark;
}

sub getMark {
  my ($this, $path) = @_;
  return $this->{cache}->{$path->hashKey()};
}

return 1;
