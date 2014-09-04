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

# Binary executable
package SMake::Platform::GCC::Bin;

use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::OptionList;
use SMake::Model::Const;
use SMake::Platform::Generic::Bin;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;

sub register {
  my ($class, $toolchain, $constructor, $compstage, $compset, $linkstage) = @_;

  # -- generic parts
  $toolchain->registerFeature(
      SMake::Platform::Generic::Bin,
      $linkstage,
      'Dir() . Name()');

  # -- register standard compilers
  $toolchain->registerFeature(
      $compset,
      $compstage,
      '.o',
      "no");
}

sub staticRegister {
  my ($class, $toolchain) = @_;
  
  # -- rpath profile (compilation of paths of dlls)
  $toolchain->registerProfile(
      "rpath",
      SMake::Profile::InstallPaths,
      $SMake::Platform::Generic::Const::BIN_TASK,
      $SMake::Platform::Generic::Const::RPATH_GROUP,
      $SMake::Platform::Generic::Const::LIB_MODULE,
      1);

  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Platform::Generic::Const::BIN_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "g++",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Platform::Generic::Const::RPATH_GROUP, 1, "", "", "-Wl,-rpath=", "", " "),
              "-Wl,--no-as-needed",
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Platform::Generic::Const::LIBDIR_GROUP, 1, "", "", "-L", "", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::LIB_GROUP, 1, "", "", "-l:", "", " ", 1, 'Name() . "." . Suffix()'),
          ),
      )],
  );
}

return 1;
