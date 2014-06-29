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

# Generic library main resource record
package SMake::Platform::Generic::LibResource;

use SMake::ToolChain::Constructor::MainResource;

@ISA = qw(SMake::ToolChain::Constructor::MainResource);

use SMake::Model::Const;

# Create new library main resource record
#
# Usage: new($libsuffix)
#    libsuffix ..... suffix of library files (usually ".a")
sub new {
  my ($class, $libsuffix) = @_;
  my $this = bless(
      SMake::ToolChain::Constructor::MainResource->new(
          $SMake::Model::Const::LIB_MAIN_TYPE,
          'Dir() . Name() . "' . $libsuffix . '"',
          $SMake::Model::Const::LIB_STAGE,
          $SMake::Model::Const::LIB_TASK, {}),
      $class);
  return $this;
}

return 1;
