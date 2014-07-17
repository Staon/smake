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
package SMake::Platform::Aveco::Bin;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Const;
use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileCompositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::OptionList;
use SMake::Executor::Translator::Select;
use SMake::Model::Const;
use SMake::Platform::Aveco::Compilers;
use SMake::Platform::Aveco::StackSize;
use SMake::Platform::Generic::Bin;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Profile::InstallPaths;
use SMake::ToolChain::Resolver::Link;

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- generic parts
  $toolchain->registerFeature(
      SMake::Platform::Generic::Bin, 'Dir() . Name()', '[.]lnk$');
  
  # -- construct the .lnk file
  my $resolver = SMake::ToolChain::Resolver::Link->new(
      '.*',
      '[.]o$',
      $SMake::Model::Const::BIN_MAIN_TYPE,
      'Dir() . Name() . ".lnk"',
      "aveco_linker",
      $SMake::Model::Const::BIN_MAIN_TYPE_LINKER);
  $constructor->appendResolver($resolver);

  # -- register standard compilers
  $toolchain->registerFeature(
      SMake::Platform::Aveco::Compilers, $SMake::Model::Const::BIN_COMPILE_STAGE);
}

sub staticRegister {
  my ($class, $toolchain, $constructor) = @_;

  # -- it appends library directories from the installation area
  $toolchain->appendProfile(SMake::Profile::InstallPaths->new(
      "aveco_linker",
      $SMake::Executor::Const::LIBDIR_GROUP,
      $SMake::Model::Const::LIB_MODULE,
      0));
  
  # -- aveco linker builder
  $toolchain->getBuilder()->appendBuilders(
    ["aveco_linker", SMake::Executor::Builder::Compile->new(
        "addResources", "addLibraries")]);
  
  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      ["aveco_linker", SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::FileCompositor->new(
              "\n",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, 0, "", "", "", "", "", 0),
              "FORM qnx flat",
              "OPTION c",
              "OPTION priv=3",
              SMake::Executor::Translator::Select->new(
                  $SMake::Executor::Const::DEBUG_GROUP . "/type", 1, "",
                  ["full", "DEBUG dwarf"],
                  ["profiler", "DEBUG all"],
                  ["no", ""]),
              SMake::Platform::Aveco::StackSize->new($SMake::Executor::Const::LIBDIR_GROUP),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Executor::Const::LIBDIR_GROUP, 1, "", "", "LIBPATH ", "", "\n"),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::LIB_GROUP, 1, "", "", "LIB ", "", "\n", 1, 'Name() . "." . Suffix()'),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, 0, "", "", "FILE ", "", "\n", 1))
      )],
      [$SMake::Model::Const::BIN_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "wlink op q",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, 0, "", "", "name ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, 0, "", "", "@", "", " ", 1))
      )]
  );
}

return 1;
