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

# C compiler feature
package SMake::Platform::Aveco::CCompiler;

use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::OptionList;
use SMake::Executor::Translator::Select;
use SMake::Executor::Translator::ValueList;
use SMake::Model::Const;
use SMake::Platform::Generic::CCompiler;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;

sub register {
  my ($class, $toolchain, $constructor, $stage) = @_;
  
  # -- register generic parts
  my $mangler = 'Dir() . Name() . ".o"';
  $toolchain->registerFeature(SMake::Platform::Generic::CCompiler, $stage, $mangler, "no");
}

sub staticRegister {
  my ($class, $toolchain, $constructor) = @_;
  
  # -- create command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Platform::Generic::Const::C_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "cc",
              SMake::Executor::Translator::Select->new(
                  $SMake::Platform::Generic::Const::DEBUG_GROUP . "/" . $SMake::Platform::Generic::Const::DEBUG_TYPE,
                  1,
                  "",
                  ["full", "-g2d"],
                  ["profiler", "-g1"],
                  ["no", ""]),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Platform::Generic::Const::CFLAGS_GROUP, 1, "", "", "", "", " "),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Platform::Generic::Const::HEADERDIR_GROUP, 1, "", "", "-I", "", " "),
              SMake::Executor::Translator::ValueList->new(
                  $SMake::Platform::Generic::Const::PREPROC_GROUP, 1, "", "", "-D", "", "=", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "-c ", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1)),
      )],
  );
}

return 1;
