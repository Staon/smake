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

# Register generic objects for the GNU Bison generator
package SMake::Platform::Generic::Bison;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Resources;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::OptionValue;
use SMake::Model::Const;
use SMake::Platform::Generic::BisonPrefix;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;
use SMake::Profile::ValueProfile;
use SMake::ToolChain::Resolver::Compile;
use SMake::ToolChain::Resolver::Filter;
use SMake::ToolChain::Resolver::Multi;
use SMake::ToolChain::Resolver::ResourceTrans;
use SMake::ToolChain::Resolver::Scanner;
use SMake::ToolChain::Scanner::Fixed;
use SMake::Utils::Masks;

# Usage: register($toolchain, $constructor, $stage, $mangler, $libtype)
#    toolchain ...... the platform toolchain
#    constructor .... current constructor
sub register {
  my ($class, $toolchain, $constructor) = @_;
  
  # -- resolve file suffixes
  $toolchain->createObject(
      "bison_sources",
      SMake::ToolChain::Resolver::ResourceTrans,
      sub { $constructor->appendResolver($_[0]); },
      SMake::Utils::Masks::createMask($SMake::Model::Const::SOURCE_RESOURCE),
      '[.]y$',
      $SMake::Platform::Generic::Const::BISON_RESOURCE,
      undef,
      undef);
  
  # -- resolver
  $toolchain->createObject(
      "bison_compiler",
      SMake::ToolChain::Resolver::Filter,
      sub { $constructor->appendResolver($_[0]); },
      SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::BISON_RESOURCE),
      '.*',
      SMake::ToolChain::Resolver::Multi->new(
          SMake::ToolChain::Resolver::Compile->new(
              '.*',
              '.*',
              $SMake::Platform::Generic::Const::BISON_STAGE,
              $SMake::Platform::Generic::Const::BISON_TASK,
              [
                $SMake::Platform::Generic::Const::CXX_RESOURCE,
                'Dir() . Name() . ".tab.cpp"',
              ],
              [
                $SMake::Platform::Generic::Const::H_RESOURCE,
                'Dir() . Name() . ".tab.hpp"',
              ],
              [
                $SMake::Platform::Generic::Const::H_RESOURCE,
                '"location.hh"',
              ],
              [
                $SMake::Platform::Generic::Const::H_RESOURCE,
                '"position.hh"',
              ],
              [
                $SMake::Platform::Generic::Const::H_RESOURCE,
                '"stack.hh"',
              ],
              [
                $SMake::Platform::Generic::Const::EXTRA_RESOURCE,
                'Dir() . Name() . ".output"',
              ],
          ),
          SMake::ToolChain::Resolver::Scanner->new(
              '.*',
              '.*',
              undef,
              $SMake::Platform::Generic::Const::CXX_RESOURCE,
              'Dir() . Name() . ".tab.cpp"',
              SMake::ToolChain::Scanner::Fixed,
              1,
              [
                [$SMake::Platform::Generic::Const::HEADER_MODULE, 'Dir() . Name() . ".hpp"'],
              ],
          ),
          SMake::ToolChain::Resolver::Scanner->new(
              '.*',
              '.*',
              undef,
              $SMake::Platform::Generic::Const::H_RESOURCE,
              'Dir() . Name() . ".tab.hpp"',
              SMake::ToolChain::Scanner::Fixed,
              1,
              [
                [$SMake::Platform::Generic::Const::HEADER_MODULE, '"stack.hh"'],
                [$SMake::Platform::Generic::Const::HEADER_MODULE, '"location.hh"'],
              ],
          ),
          SMake::ToolChain::Resolver::Scanner->new(
              '.*',
              '.*',
              undef,
              $SMake::Platform::Generic::Const::H_RESOURCE,
              '"stack.hh"',
              SMake::ToolChain::Scanner::Fixed,
              1,
              [],
          ),
          SMake::ToolChain::Resolver::Scanner->new(
              '.*',
              '.*',
              undef,
              $SMake::Platform::Generic::Const::H_RESOURCE,
              '"position.hh"',
              SMake::ToolChain::Scanner::Fixed,
              1,
              [],
          ),
          SMake::ToolChain::Resolver::Scanner->new(
              '.*',
              '.*',
              undef,
              $SMake::Platform::Generic::Const::H_RESOURCE,
              '"location.hh"',
              SMake::ToolChain::Scanner::Fixed,
              1,
              [],
          ),
      ),
  );

  # -- headers included from the flex source file
  $toolchain->registerFeature(
      [SMake::Platform::Generic::HeaderScanner,
       SMake::Utils::Masks::createMask($SMake::Platform::Generic::Const::BISON_RESOURCE)]);

  # -- bison/flex prefix profile
  $toolchain->registerFeature(SMake::Platform::Generic::BisonPrefix);
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::BISON_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP,
            $SMake::Platform::Generic::Const::BISON_RESOURCE),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP,
            $SMake::Platform::Generic::Const::CXX_RESOURCE),
    )],
  );

  # -- create command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Platform::Generic::Const::BISON_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              1,
              "bison",
              "-v",
              SMake::Executor::Translator::OptionValue->new(
                  $SMake::Platform::Generic::Const::BISON_GROUP . "/" . $SMake::Platform::Generic::Const::BISON_PREFIX,
                  1,
                  "-Dapi.namespace='{",
                  "}'"),
              SMake::Executor::Translator::OptionValue->new(
                  $SMake::Platform::Generic::Const::BISON_GROUP . "/" . $SMake::Platform::Generic::Const::BISON_PREFIX,
                  1,
                  "-Dapi.prefix='{",
                  "}'"),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::PRODUCT_GROUP, 0, "", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "-d ", "", " ", 1)),
      )],
  );
}

return 1;
