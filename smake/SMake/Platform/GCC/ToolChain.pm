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

# Toolchain for GCC compiler
package SMake::Platform::GCC::ToolChain;

use SMake::Model::Const;
use SMake::Platform::GCC::Bin;
use SMake::Platform::GCC::Dll;
use SMake::Platform::GCC::HeaderFilter;
use SMake::Platform::GCC::Lib;
use SMake::Platform::Generic::Const;
use SMake::Platform::Generic::Debug;
use SMake::Platform::Generic::Preproc;
use SMake::Platform::Generic::ToolChain;
use SMake::Profile::ValueProfile;
use SMake::ToolChain::ResourceFilter::SysLocation;

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- nothing to do
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- empty artifact
  $toolchain->registerConstructor($SMake::Platform::Generic::Const::EMPTY_ARTIFACT);
  $toolchain->registerFeature(SMake::Platform::Generic::CHeader);
  
  # -- library artifact
  $toolchain->registerConstructor($SMake::Platform::Generic::Const::LIB_ARTIFACT);
  $toolchain->registerFeature(SMake::Platform::GCC::Dll);
  $toolchain->registerFeature(SMake::Platform::GCC::Lib);

  # -- binary artifact
  $toolchain->registerConstructor($SMake::Platform::Generic::Const::BIN_ARTIFACT);
  $toolchain->registerFeature(SMake::Platform::GCC::Bin);

  # -- generic preprocessor profile
  $toolchain->registerFeature(SMake::Platform::Generic::Preproc);
  
  # -- debug options
  $toolchain->registerFeature(SMake::Platform::Generic::Debug);

  # -- resource filters
  $toolchain->getResourceFilter()->appendFilters(
      SMake::Platform::GCC::HeaderFilter->new(),
  );
}

return 1;
