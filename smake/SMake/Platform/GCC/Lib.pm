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

# Static library
package SMake::Platform::GCC::Lib;

use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Model::Const;
use SMake::Platform::Generic::Lib;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;
use SMake::Utils::Masks;

sub register {
  my ($class, $toolchain, $constructor, $compset, $extrares) = @_;

  # -- generic parts
  my $linkspec = [];
  if(defined($extrares)) {
    foreach my $extra (@$extrares) {
      my ($maintype, $ressuffix, $objmask) = @$extra;
      push @$linkspec, [
        $maintype,
        'Dir() . Name() . "' . $ressuffix . '.a"',
        SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::OBJ_RESOURCE),
        $objmask . '[.]a[.]o$',
      ];
    }
  }
  push @$linkspec, [
    $SMake::Platform::Generic::Const::LIB_MAIN_TYPE,
    'Dir() . Name() . ".a"',
    SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::OBJ_RESOURCE),
    '[.]a[.]o$',
  ];
  $toolchain->registerFeature(SMake::Platform::Generic::Lib, $linkspec);

  # -- register standard compilers
  $toolchain->registerFeature(
      $compset,
      $SMake::Platform::Generic::Const::LIB_COMPILE_STAGE,
      '.a.o',
      "static");
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Platform::Generic::Const::LIB_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              1,
              "ar rs",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                   $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1)),
      )]
  );
}

return 1;
