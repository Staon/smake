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

# Standard set of compilers
package SMake::Platform::GCC::Compilers;

use SMake::Platform::GCC::CCompiler;
use SMake::Platform::GCC::CXXCompiler;
use SMake::Platform::Generic::Bison;
use SMake::Platform::Generic::Direct;
use SMake::Platform::Generic::ExtraFiles;
use SMake::Platform::Generic::Flex;

sub register {
  my ($class, $toolchain, $constructor, $stage, $objsuffix, $libtype) = @_;
  
  $toolchain->registerFeature(
      SMake::Platform::GCC::CCompiler, $stage, $objsuffix, $libtype);
  $toolchain->registerFeature(
      SMake::Platform::GCC::CXXCompiler, $stage, $objsuffix, $libtype);
  $toolchain->registerFeature(
      SMake::Platform::Generic::Flex);
  $toolchain->registerFeature(
      SMake::Platform::Generic::Bison);
  $toolchain->registerFeature(
      SMake::Platform::Generic::ExtraFiles);
  $toolchain->registerFeature(
      SMake::Platform::Generic::Direct);
}

sub staticRegister {
  # -- nothing to do
}

return 1;
