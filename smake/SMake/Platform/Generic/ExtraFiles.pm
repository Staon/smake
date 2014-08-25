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

# Extra files
package SMake::Platform::Generic::ExtraFiles;

use SMake::Platform::Generic::Const;
use SMake::ToolChain::Resolver::Empty;
use SMake::Utils::Masks;

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- resolve file suffixes
  $toolchain->createObject(
      "extra_files",
      SMake::ToolChain::Resolver::Empty,
      sub { $constructor->appendResolver($_[0]); },
      SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::EXTRA_RESOURCE),
      '.*');
}

sub staticRegister {
  my ($class, $toolchain) = @_;

}

return 1;
