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

# Dynamic library
package SMake::Platform::GCC::Dll;

use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Model::Const;
use SMake::Platform::Generic::Dll;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;
use SMake::Utils::Masks;

sub register {
  my ($class, $toolchain, $constructor, $compset, $extrares) = @_;

  my $linkspec = [];
  if(defined($extrares)) {
    foreach my $extra (@$extrares) {
      my ($maintype, $ressuffix, $objmask) = @$extra;
      push @$linkspec, [
        $maintype,
        'Dir() . Name() . "' . $ressuffix . '.so"',
        SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::OBJ_RESOURCE),
        $objmask . '[.]so[.]o$',
      ];
    }
  }
  push @$linkspec, [
    $SMake::Platform::Generic::Const::DLL_MAIN_TYPE,
    'Dir() . Name() . ".so"',
    SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::OBJ_RESOURCE),
    '[.]so[.]o$',
  ];
  
  # -- generic parts
  $toolchain->registerFeature(SMake::Platform::Generic::Dll, $linkspec);

  # -- register standard compilers
  $toolchain->registerFeature(
      $compset,
      $SMake::Platform::Generic::Const::DLL_COMPILE_STAGE,
      '.so.o',
      "dll");
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Platform::Generic::Const::DLL_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              1,
              "gcc",
              "-shared",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "-Wl,-soname,", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                   $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1)),
      )]
  );
}

return 1;
