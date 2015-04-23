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
use SMake::Platform::Generic::Link;

sub register {
  my ($class, $toolchain, $constructor, $speclist) = @_;
  
  my $linkspec = [];
  foreach my $spec (@$speclist) {
    my ($maintype, $mangler, $objecttype, $objectmask) = @$spec;
    push @$linkspec, [
          $SMake::Platform::Generic::Const::DLL_TASK,
          $objecttype,
          $objectmask,
          $maintype,
          $SMake::Platform::Generic::Const::DLL_RESOURCE,
          $mangler,
          0,
        ];
  }

  $toolchain->registerFeature(
      SMake::Platform::Generic::Link,
      $SMake::Platform::Generic::Const::DLL_STAGE,
      $linkspec);
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
