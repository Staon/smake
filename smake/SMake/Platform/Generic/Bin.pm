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
use SMake::Executor::Builder::Empty;
use SMake::Executor::Builder::Resources;
use SMake::Platform::Generic::Compile;
use SMake::Platform::Generic::Const;
use SMake::Platform::Generic::DepInstall;
use SMake::Platform::Generic::Link;
use SMake::Profile::InstallPaths;

$DEFAULT_AFTER_BIN_TASK = "bin_empty_task";

sub register {
  my ($class, $toolchain, $constructor, $stage, $resname) = @_;

  # -- register main resource
  my $resolver = $toolchain->registerFeature(
      SMake::Platform::Generic::Link,
      $stage,
      [
        [
          $SMake::Platform::Generic::Const::BIN_TASK,
          $SMake::Platform::Generic::Const::OBJ_RESOURCE,
          '.*',
          $SMake::Platform::Generic::Const::BIN_MAIN_TYPE,
          $SMake::Platform::Generic::Const::BIN_RESOURCE,
          $resname,
          1,
        ],
      ]);
  
  # -- linking dependencies
  $toolchain->registerFeature(
      SMake::Platform::Generic::DepInstall,
      $SMake::Platform::Generic::Const::LINK_DEPENDENCY,
      $SMake::Platform::Generic::Const::BIN_MAIN_TYPE,
      $SMake::Platform::Generic::Const::LIB_INSTALL_STAGE,
      $SMake::Platform::Generic::Const::LIB_INSTALL_DEPENDENCY,
      $SMake::Platform::Generic::Const::LIB_MODULE);

  # -- it appends library directories from the installation area
  $toolchain->createObject(
      "bin::link::install_paths",
      SMake::Profile::InstallPaths,
      sub { $constructor->appendProfile($_[0]); },
      $SMake::Platform::Generic::Const::BIN_TASK,
      $SMake::Platform::Generic::Const::LIBDIR_GROUP,
      $SMake::Platform::Generic::Const::LIB_MODULE,
      1,
  );

  # -- default empty task for resolving of the binary resource
  $toolchain->registerFeature(
      SMake::Platform::Generic::Compile,
      $DEFAULT_AFTER_BIN_TASK,
      $stage,
      $SMake::Platform::Generic::Const::BIN_RESOURCE,
      '.*',
  );
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::BIN_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $SMake::Platform::Generic::Const::OBJ_RESOURCE),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $SMake::Platform::Generic::Const::BIN_RESOURCE),
        SMake::Executor::Builder::Dependencies::simpleRecord(
            $SMake::Platform::Generic::Const::LIB_GROUP,
            $SMake::Platform::Generic::Const::LINK_DEPENDENCY),
    )],
    [$DEFAULT_AFTER_BIN_TASK, SMake::Executor::Builder::Empty->new()],
  );
}

return 1;
