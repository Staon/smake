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

# Generic binary main resource record
package SMake::Platform::Generic::BinResource;

use SMake::ToolChain::Constructor::MainResource;

@ISA = qw(SMake::ToolChain::Constructor::MainResource);

use SMake::Model::Const;

# Create new library main resource record
#
# Usage: new($binsuffix)
#    libsuffix ..... suffix of binary files (usually "")
sub new {
  my ($class, $binsuffix) = @_;
  my $this = bless(
      SMake::ToolChain::Constructor::MainResource->new(
          $SMake::Model::Const::BIN_MAIN_TYPE,
          'Dir() . Name() . "' . $binsuffix . '"',
          $SMake::Model::Const::BIN_STAGE,
          $SMake::Model::Const::BIN_TASK, {}),
      $class);
  return $this;
}

return 1;
