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

# Generic static binary feature
package SMake::Platform::Generic::Bin;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Dependencies;
use SMake::Executor::Builder::Resources;
use SMake::Platform::Generic::Const;
use SMake::Profile::InstallPaths;
use SMake::ToolChain::Constructor::MainResource;
use SMake::ToolChain::Resolver::DepInstall;
use SMake::ToolChain::Resolver::DepResource;
use SMake::ToolChain::Resolver::Link;

sub register {
  my ($class, $toolchain, $constructor, $taskname, $srcres, $mangler, $objecttype, $objectmask) = @_;
  
  # -- register main resource
  my $mres = SMake::ToolChain::Constructor::MainResource->new(
      $SMake::Platform::Generic::Const::BIN_RESOURCE,
      $SMake::Platform::Generic::Const::BIN_MAIN_TYPE,
      $mangler,
      $SMake::Platform::Generic::Const::BIN_STAGE,
      $SMake::Platform::Generic::Const::BIN_TASK,
      0,
      {});
  $constructor->appendMainResource($mres);
  
  # -- register the linker resolver
  my $resolver = SMake::ToolChain::Resolver::Link->new(
      $objecttype,
      $objectmask,
      $SMake::Platform::Generic::Const::BIN_MAIN_TYPE);
  $constructor->appendResolver($resolver);

  # -- linking dependencies
  $resolver = SMake::ToolChain::Resolver::Multi->new(
      SMake::ToolChain::Resolver::DepResource->new(
          '^' . $SMake::Platform::Generic::Const::LINK_DEPENDENCY . '$',
          [[$SMake::Platform::Generic::Const::BIN_MAIN_TYPE_LINKER, 
            $SMake::Platform::Generic::Const::BIN_MAIN_TYPE]],
      ),
      SMake::ToolChain::Resolver::DepInstall->new(
          '^' . $SMake::Platform::Generic::Const::LINK_DEPENDENCY . '$',
          $SMake::Platform::Generic::Const::LIB_INSTALL_STAGE,
          [[$SMake::Platform::Generic::Const::BIN_MAIN_TYPE_LINKER,
            $SMake::Platform::Generic::Const::BIN_MAIN_TYPE]],
          $SMake::Platform::Generic::Const::LIB_INSTALL_DEPENDENCY,
          $SMake::Platform::Generic::Const::LIB_MODULE));
  $constructor->appendResolver($resolver);
}

sub staticRegister {
  my ($class, $toolchain, $constructor, $task, $srcres) = @_;

  # -- it appends library directories from the installation area
  $toolchain->appendProfile(SMake::Profile::InstallPaths->new(
      $SMake::Platform::Generic::Const::BIN_TASK,
      $SMake::Platform::Generic::Const::LIBDIR_GROUP,
      $SMake::Platform::Generic::Const::LIB_MODULE,
      1)
  );

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$task, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $srcres),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $SMake::Platform::Generic::Const::BIN_RESOURCE),
        SMake::Executor::Builder::Dependencies::simpleRecord(
            $SMake::Platform::Generic::Const::LIB_GROUP,
            $SMake::Platform::Generic::Const::LINK_DEPENDENCY),
    )],
  );
}

return 1;
