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
use SMake::Executor::Const;
use SMake::Model::Const;
use SMake::Platform::Generic::CHeader;
use SMake::Platform::Generic::HeaderScanner;
use SMake::Profile::InstallPaths;
use SMake::Profile::LocalDirs;
use SMake::Profile::ValueProfile;
use SMake::ToolChain::Resolver::Compile;
use SMake::ToolChain::Resolver::Multi;

# Usage: register($toolchain, $construct, $mangler)
#    toolchain ...... the platform toolchain
#    construct ...... current constructor
#    constructor .... current constructor
#    mangler ........ mangler description
#    libtype ........ "no", "static", "dll" 
sub register {
  my ($class, $toolchain, $constructor, $mangler, $libtype) = @_;
  
  # -- resolver
  my $multi = $toolchain->createObject(
      "C_compiler",
      SMake::ToolChain::Resolver::Multi,
      sub { $constructor->appendResolver($_[0]); });
  my $resolver = SMake::ToolChain::Resolver::Compile->new(
      '.*',
      '[.]c$',
      $mangler,
      $SMake::Model::Const::COMPILE_STAGE,
      $SMake::Model::Const::C_TASK);
  $multi->appendResolver($resolver);

  # -- type of library
  my $profile = SMake::Profile::ValueProfile->new(
      '^' . quotemeta($SMake::Model::Const::C_TASK) . '$',
      $SMake::Executor::Const::DLL_GROUP,
      0,
      $SMake::Executor::Const::LIB_TYPE_OPTION, $libtype);
  $resolver->appendProfile($profile);
  
  # -- C headers
  $toolchain->registerFeature([SMake::Platform::Generic::HeaderScanner, '[.]c$']);
  $toolchain->registerFeature(SMake::Platform::Generic::CHeader);
}

sub staticRegister {
  my ($class, $toolchain, $constructor) = @_;

  # -- include directories from the installation area
  $toolchain->appendProfile(SMake::Profile::InstallPaths->new(
      $SMake::Model::Const::C_TASK,
      $SMake::Executor::Const::HEADERDIR_GROUP,
      $SMake::Model::Const::HEADER_MODULE,
      1));
  # -- local header paths
  $toolchain->appendProfile(SMake::Profile::LocalDirs->new(
      $SMake::Model::Const::C_TASK,
      $SMake::Executor::Const::HEADERDIR_GROUP,
      "^" . quotemeta($SMake::Model::Const::HEADER_MODULE . "/"),
      1));

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Model::Const::C_TASK, SMake::Executor::Builder::Compile->new()]);
}

return 1;
