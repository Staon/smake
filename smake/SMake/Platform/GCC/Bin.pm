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

use SMake::Executor::Const;
use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::OptionList;
use SMake::Model::Const;
use SMake::Platform::GCC::Compilers;
use SMake::Platform::Generic::Bin;
use SMake::Platform::Generic::CompileTranslator;

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- generic parts
  $toolchain->registerFeature(
      SMake::Platform::Generic::Bin, 'Dir() . Name()', '.o$');

  # -- register standard compilers
  $toolchain->registerFeature(SMake::Platform::GCC::Compilers, '.o', "no");
}

sub staticRegister {
  my ($class, $toolchain, $constructor) = @_;
  
  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Model::Const::BIN_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "g++",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, 0, "", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Executor::Const::LIBDIR_GROUP, 1, "", "", "-L", "", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::LIB_GROUP, 1, "", "", "-l:", "", " ", 1, 'Name() . "." . Suffix()'),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::LIB_GROUP, 1, "", "", "-l:", "", " ", 1, 'Name() . "." . Suffix()'),
          ),
      )]);
}

return 1;
