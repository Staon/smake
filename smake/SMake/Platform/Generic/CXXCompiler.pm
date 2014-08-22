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

# Register generic objects for C++ compiling
package SMake::Platform::Generic::CXXCompiler;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Resources;
use SMake::Model::Const;
use SMake::Platform::Generic::CHeader;
use SMake::Platform::Generic::Const;
use SMake::Platform::Generic::HeaderScanner;
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
  $toolchain->createObject(
      "CXX_sources",
      SMake::ToolChain::Resolver::ResourceTrans,
      sub { $constructor->appendResolver($_[0]); },
      '^' . quotemeta($SMake::Model::Const::SOURCE_RESOURCE) . '$',
      '[.]cpp$',
      $SMake::Platform::Generic::Const::CXX_RESOURCE,
      undef,
      undef);
  
  # -- resolver
  my $multi = $toolchain->createObject(
      "CXX_compiler",
      SMake::ToolChain::Resolver::Multi,
      sub { $constructor->appendResolver($_[0]); });
  my $resolver = SMake::ToolChain::Resolver::Compile->new(
      '^' . quotemeta($SMake::Platform::Generic::Const::CXX_RESOURCE) . '$',
      '.*',
      $stage,
      $SMake::Platform::Generic::Const::CXX_TASK,
      [$SMake::Platform::Generic::Const::OBJ_RESOURCE, $mangler],
  );
  $multi->appendResolver($resolver);

  # -- type of library
  my $profile = SMake::Profile::ValueProfile->new(
      '^' . quotemeta($SMake::Platform::Generic::Const::CXX_TASK) . '$',
      $SMake::Platform::Generic::Const::DLL_GROUP,
      0,
      $SMake::Platform::Generic::Const::LIB_TYPE_OPTION,
      $libtype);
  $resolver->appendProfile($profile);
  
  # -- C headers
  $toolchain->registerFeature(
      [SMake::Platform::Generic::HeaderScanner,
       '^' . $SMake::Platform::Generic::Const::CXX_RESOURCE . '$']);
  $toolchain->registerFeature(SMake::Platform::Generic::CHeader);
}

sub staticRegister {
  my ($class, $toolchain, $constructor) = @_;

  # -- include directories from the installation area
  $toolchain->appendProfile(SMake::Profile::InstallPaths->new(
      $SMake::Platform::Generic::Const::CXX_TASK,
      $SMake::Platform::Generic::Const::HEADERDIR_GROUP,
      $SMake::Platform::Generic::Const::HEADER_MODULE,
      1),
  );
  # -- local include directories
  $toolchain->appendProfile(SMake::Profile::LocalDirs->new(
      '^' . quotemeta($SMake::Platform::Generic::Const::CXX_TASK) . '$',
      $SMake::Platform::Generic::Const::HEADERDIR_GROUP,
      '^' . quotemeta($SMake::Platform::Generic::Const::HEADER_MODULE) . '$',
      '.*',
      1),
  );

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::CXX_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $SMake::Platform::Generic::Const::CXX_RESOURCE),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $SMake::Platform::Generic::Const::OBJ_RESOURCE),
    )],
  );
}

return 1;
