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

# Register generic objects for C compiling
package SMake::Platform::Generic::CCompiler;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Resources;
use SMake::Model::Const;
use SMake::Platform::Generic::CHeader;
use SMake::Platform::Generic::Compile;
use SMake::Platform::Generic::Const;
use SMake::Platform::Generic::HeaderScanner;
use SMake::Platform::Generic::Source;
use SMake::Profile::InstallPaths;
use SMake::Profile::LocalDirs;
use SMake::Profile::ValueProfile;
use SMake::ToolChain::Resolver::Compile;
use SMake::ToolChain::Resolver::Multi;
use SMake::ToolChain::Resolver::ResourceTrans;

# Usage: register($toolchain, $construct, $stage, $mangler, $libtype)
#    toolchain ...... the platform toolchain
#    constructor .... current constructor
#    stage .......... compilation stage
#    mangler ........ mangler description
#    libtype ........ "no", "static", "dll"
sub register {
  my ($class, $toolchain, $constructor, $stage, $mangler, $libtype) = @_;
  
  # -- resolve file suffixes
  $toolchain->registerFeature(
      SMake::Platform::Generic::Source,
      '[.]c$',
      $SMake::Platform::Generic::Const::C_RESOURCE);
  
  # -- compilation task
  my $resolver = $toolchain->registerFeature(
      SMake::Platform::Generic::Compile,
      $SMake::Platform::Generic::Const::C_TASK,
      $stage,
      $SMake::Platform::Generic::Const::C_RESOURCE,
      '.*',
      [$SMake::Platform::Generic::Const::OBJ_RESOURCE, $mangler]);

  # -- type of library (profile)
  my $profile = SMake::Profile::ValueProfile->new(
      SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::C_TASK),
      $SMake::Platform::Generic::Const::DLL_GROUP,
      0,
      $SMake::Platform::Generic::Const::LIB_TYPE_OPTION,
      $libtype);
  $resolver->appendProfile($profile);

  # -- C++ header scanner
  $toolchain->registerFeature(
      [SMake::Platform::Generic::HeaderScanner,
       SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::C_RESOURCE)]);
  
  # -- C/C++ headers
  $toolchain->registerFeature(SMake::Platform::Generic::CHeader);

  # -- include directories from the installation area
  $toolchain->createObject(
      "C::compile::install_paths",
      SMake::Profile::InstallPaths,
      sub { $constructor->appendProfile($_[0]); },
      $SMake::Platform::Generic::Const::C_TASK,
      $SMake::Platform::Generic::Const::HEADERDIR_GROUP,
      $SMake::Platform::Generic::Const::HEADER_MODULE,
      1,
  );
  
  # -- local include directories
  $toolchain->createObject(
      "C::compile::local_dirs",
      SMake::Profile::LocalDirs,
      sub { $constructor->appendProfile($_[0]); },
      SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::C_TASK),
      $SMake::Platform::Generic::Const::HEADERDIR_GROUP,
      SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::HEADER_MODULE),
      '.*',
      1,
  );

  return $resolver;
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::C_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $SMake::Platform::Generic::Const::C_RESOURCE),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $SMake::Platform::Generic::Const::OBJ_RESOURCE),
    )],
  );
}

return 1;
