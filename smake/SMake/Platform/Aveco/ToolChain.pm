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

# Toolchain for Aveco building environment (QNX4, OpenWatcom)
package SMake::Platform::Aveco::ToolChain;

use SMake::Platform::Generic::ToolChain;

@ISA = qw(SMake::Platform::Generic::ToolChain);

use SMake::Model::Const;
use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::Instruction;
use SMake::Executor::Translator::OptionList;
use SMake::Executor::Translator::Select;
use SMake::Executor::Translator::Sequence;
use SMake::Platform::Generic::BinResolver;
use SMake::Platform::Generic::BinResource;
use SMake::Platform::Generic::CleanTranslator;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::CResolver;
use SMake::Platform::Generic::CXXResolver;
use SMake::Platform::Generic::HeaderResolver;
use SMake::Platform::Generic::InstallTranslator;
use SMake::Platform::Generic::LibResolver;
use SMake::Platform::Generic::LibResource;
use SMake::Platform::Generic::LinkResolver;
use SMake::ToolChain::Constructor::Generic;
use SMake::ToolChain::Resolver::Chain;
use SMake::ToolChain::ResourceFilter::SysLocation;
use SMake::ToolChain::Scanner::HdrScanner;

# Create the toolchain
#
# Usage: new($runner)
#    $runner ...... parent tool chain
sub new {
  my ($class, $runner) = @_;
  my $this = bless(SMake::Platform::Generic::ToolChain->new($runner));

  # -- artifact constructors (lib and binary)
  my $objsuff = ".o";
  $this->getConstructor()->appendConstructors(
    [$SMake::Model::Const::LIB_ARTIFACT, SMake::ToolChain::Constructor::Generic->new(
        SMake::ToolChain::Resolver::Chain->new(
            SMake::Platform::Generic::CResolver->new($objsuff),
            SMake::Platform::Generic::CXXResolver->new($objsuff),
            SMake::Platform::Generic::HeaderResolver->new(),
            SMake::Platform::Generic::LibResolver->new($objsuff),
        ),
        [SMake::Platform::Generic::LibResource->new(".lib")],
    )],
    [$SMake::Model::Const::BIN_ARTIFACT, SMake::ToolChain::Constructor::Generic->new(
        SMake::ToolChain::Resolver::Chain->new(
            SMake::Platform::Generic::CResolver->new($objsuff),
            SMake::Platform::Generic::CXXResolver->new($objsuff),
            SMake::Platform::Generic::HeaderResolver->new(),
            SMake::Platform::Generic::BinResolver->new($objsuff),
            SMake::Platform::Generic::LinkResolver->new(),
        ),
        [SMake::Platform::Generic::BinResource->new("")],
    )],
  );

  # -- command translators
  $this->getTranslator()->appendRecords(
      [$SMake::Model::Const::C_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "cc",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, "-c ", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
      )],
      [$SMake::Model::Const::CXX_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "cc",
              SMake::Executor::Translator::OptionList->new(
                  "header_dirs", "", "", "-I", "", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, "-c ", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
      )],
      [$SMake::Model::Const::LIB_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "wlib -b",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, "", "", "", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                   $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
      )],
      [$SMake::Model::Const::BIN_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "cc",
              SMake::Executor::Translator::OptionList->new(
                  "lib_dirs", "", "", "-L ", "", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::LIB_GROUP, "-liost -lunix3r ", "", "-l", "", " ", 1, 'Name() . "." . Suffix()'),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, "", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
      )],
      [$SMake::Model::Const::EXTERNAL_TASK,
          SMake::Platform::Generic::InstallTranslator->new(),
      ],
      [$SMake::Model::Const::CLEAN_TASK,
          SMake::Platform::Generic::CleanTranslator->new(),
      ],
  );
  
  # -- source scanners
  $this->getScanner()->appendScanners(
      SMake::ToolChain::Scanner::HdrScanner->new('.*', '.*', '[.](c|cpp|h)$'),
  );
  
  # -- resource filters
  $this->getResourceFilter()->appendFilters(
      SMake::ToolChain::ResourceFilter::SysLocation->new("/usr/include"),
  );
  
  return $this;
}

return 1;
