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

# Generic dynamic library feature
package SMake::Platform::Generic::Dll;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Resources;
use SMake::Model::Const;
use SMake::Platform::Generic::Const;
use SMake::ToolChain::Constructor::MainResource;
use SMake::ToolChain::Resolver::Link;

sub register {
  my ($class, $toolchain, $constructor, $mangler, $objecttype, $objectmask) = @_;
  
  # -- register main resource
  my $mres = SMake::ToolChain::Constructor::MainResource->new(
      $SMake::Platform::Generic::Const::DLL_RESOURCE,
      $SMake::Platform::Generic::Const::DLL_MAIN_TYPE,
      $mangler,
      $SMake::Platform::Generic::Const::DLL_STAGE,
      $SMake::Platform::Generic::Const::DLL_TASK,
      0,
      {});
  $constructor->appendMainResource($mres);
  
  # -- register the library resolver
  my $resolver = SMake::ToolChain::Resolver::Link->new(
      $objecttype,
      $objectmask,
      $SMake::Platform::Generic::Const::DLL_MAIN_TYPE);
  $constructor->appendResolver($resolver);
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::DLL_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $SMake::Platform::Generic::Const::OBJ_RESOURCE),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $SMake::Platform::Generic::Const::DLL_RESOURCE),
    )],
  );
}

return 1;
