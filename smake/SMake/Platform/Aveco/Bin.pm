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
use SMake::Executor::Builder::Dependencies;
use SMake::Executor::Builder::Resources;
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
use SMake::Platform::Generic::Const;
use SMake::Profile::InstallPaths;
use SMake::ToolChain::Constructor::MainResource;
use SMake::ToolChain::Resolver::Link;

$AVECO_LINK = "aveco_linker";
$AVECO_LINK_RESOURCE = "aveco_lnk";

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- generic parts
  $toolchain->registerFeature(
      [SMake::Platform::Generic::Bin,
        $SMake::Platform::Generic::Const::BIN_TASK,
        $AVECO_LINK_RESOURCE],
      'Dir() . Name()',
      '^' . quotemeta($AVECO_LINK_RESOURCE) . '$',
      '[.]lnk$');

  # -- linker main type (a main type which the library dependecies are added in)
  my $mres = SMake::ToolChain::Constructor::MainResource->new(
      $AVECO_LINK_RESOURCE,
      $SMake::Platform::Generic::Const::BIN_MAIN_TYPE_LINKER,
      'Dir() . Name() . ".lnk"',
      $SMake::Platform::Generic::Const::BIN_STAGE,
      $AVECO_LINK,
      1,
      {});
  $constructor->appendMainResource($mres);
  
  # -- construct the .lnk file
  my $resolver = SMake::ToolChain::Resolver::Link->new(
      '^' . quotemeta($SMake::Platform::Generic::Const::OBJ_RESOURCE) . '$',
      '.*',
      $SMake::Platform::Generic::Const::BIN_MAIN_TYPE_LINKER);
  $constructor->appendResolver($resolver);

  # -- register standard compilers
  $toolchain->registerFeature(
      SMake::Platform::Aveco::Compilers, $SMake::Platform::Generic::Const::BIN_COMPILE_STAGE);
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- it appends library directories from the installation area
  $toolchain->appendProfile(SMake::Profile::InstallPaths->new(
      $AVECO_LINK,
      $SMake::Platform::Generic::Const::LIBDIR_GROUP,
      $SMake::Platform::Generic::Const::LIB_MODULE,
      0));
  
  # -- aveco linker builder
  $toolchain->getBuilder()->appendBuilders(
    [$AVECO_LINK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $SMake::Platform::Generic::Const::OBJ_RESOURCE),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $AVECO_LINK_RESOURCE),
        SMake::Executor::Builder::Dependencies::simpleRecord(
            $SMake::Platform::Generic::Const::LIB_GROUP,
            $SMake::Platform::Generic::Const::LINK_DEPENDENCY),
    )],
  );
  
  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      [$AVECO_LINK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::FileCompositor->new(
              "\n",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "", "", "", 0),
              "FORM qnx flat",
              "OPTION c",
              "OPTION priv=3",
              SMake::Executor::Translator::Select->new(
                  $SMake::Platform::Generic::Const::DEBUG_GROUP . "/type", 1, "",
                  ["full", "DEBUG dwarf"],
                  ["profiler", "DEBUG all"],
                  ["no", ""]),
              SMake::Platform::Aveco::StackSize->new(
                  $SMake::Platform::Generic::Const::LIBDIR_GROUP),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Platform::Generic::Const::LIBDIR_GROUP, 1, "", "", "LIBPATH ", "", "\n"),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::LIB_GROUP, 1, "", "", "LIB ", "", "\n", 1, 'Name() . "." . Suffix()'),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "FILE ", "", "\n", 1))
      )],
      [$SMake::Platform::Generic::Const::BIN_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              1,
              "wlink",
              "op q",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "name ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "@", "", " ", 1))
      )]
  );
}

return 1;
