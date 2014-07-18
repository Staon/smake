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

# Default repository - file storage
package SMake::Repository::Default;

use SMake::InstallArea::StdArea;
use SMake::Model::Const;
use SMake::Repository::Repository;
use SMake::Storage::File::Storage;

# Create new default repository
#
# Usage: create($parent, $dir)
#    parent ..... parent repository (can be undef)
#    dir ........ repository path (an absolute string path)
# Returns: the repository
sub create {
  my ($parent, $dir) = @_;
  
  my $storage = SMake::Storage::File::Storage->new($dir);
  my $installarea = SMake::InstallArea::StdArea->new(
      $SMake::Model::Const::SOURCE_RESOURCE);
  my $repository = SMake::Repository::Repository->new(
      $parent, $storage, $installarea);
  return $repository;
}

return 1;
