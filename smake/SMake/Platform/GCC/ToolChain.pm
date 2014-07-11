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

# Toolchain for GCC compiler
package SMake::Platform::GCC::ToolChain;

use SMake::Platform::Generic::ToolChain;

@ISA = qw(SMake::Platform::Generic::ToolChain);

use SMake::Model::Const;
use SMake::Executor::Const;
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
use SMake::Platform::Generic::ServiceTranslator;
use SMake::Profile::InstallPaths;
use SMake::Profile::LocalDirs;
use SMake::Profile::VarProfile;
use SMake::ToolChain::Constructor::Generic;
use SMake::ToolChain::Resolver::Chain;
use SMake::ToolChain::ResourceFilter::SysLocation;
use SMake::ToolChain::Scanner::HdrScanner;

# Create the toolchain
#
# Usage: new($repository, $profiles)
#    repository ...... the most significant repository
#    profiles ........ profile stack
sub new {
  my ($class, $repository, $profiles) = @_;
  my $this = bless(SMake::Platform::Generic::ToolChain->new($repository, $profiles));

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
        [SMake::Platform::Generic::LibResource->new(".a")],
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

  # -- needed for header publishing (HeaderResolver)
  $repository->registerProfile(
      "header",
      SMake::Profile::VarProfile,
      $SMake::Model::Const::VAR_HEADER_DIRECTORY);
  # -- it appends include directories from the installation area
  $profiles->appendProfile(SMake::Profile::InstallPaths->new(
      $SMake::Model::Const::CXX_TASK,
      $SMake::Executor::Const::HEADERDIR_GROUP,
      $SMake::Model::Const::HEADER_MODULE,
      1));
  $profiles->appendProfile(SMake::Profile::InstallPaths->new(
      $SMake::Model::Const::C_TASK,
      $SMake::Executor::Const::HEADERDIR_GROUP,
      $SMake::Model::Const::HEADER_MODULE,
      1));
  # -- it appends local include directories
  $profiles->appendProfile(SMake::Profile::LocalDirs->new(
      $SMake::Model::Const::CXX_TASK,
      $SMake::Executor::Const::HEADERDIR_GROUP,
      "^" . quotemeta($SMake::Model::Const::HEADER_MODULE . "/"),
      1));
  $profiles->appendProfile(SMake::Profile::LocalDirs->new(
      $SMake::Model::Const::C_TASK,
      $SMake::Executor::Const::HEADERDIR_GROUP,
      "^" . quotemeta($SMake::Model::Const::HEADER_MODULE . "/"),
      1));
  # -- it appends library directories from the installation area
  $profiles->appendProfile(SMake::Profile::InstallPaths->new(
      $SMake::Model::Const::BIN_TASK,
      $SMake::Executor::Const::LIBDIR_GROUP,
      $SMake::Model::Const::LIB_MODULE,
      1));

  # -- command translators
  $this->getTranslator()->appendRecords(
      [$SMake::Model::Const::C_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "gcc",
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Executor::Const::HEADERDIR_GROUP, 1, "", "", "-I", "", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, 0, "-c ", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1)),
      )],
      [$SMake::Model::Const::CXX_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "g++",
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Executor::Const::HEADERDIR_GROUP, 1, "", "", "-I", "", " "),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, 0, "-c ", "", "-o ", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1)),
      )],
      [$SMake::Model::Const::LIB_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              "ar rs",
              SMake::Executor::Translator::FileList->new(
                  $SMake::Executor::Const::PRODUCT_GROUP, 0, "", "", "", "", "", 0),
              SMake::Executor::Translator::FileList->new(
                   $SMake::Executor::Const::SOURCE_GROUP, 0, "", "", "", "", " ", 1)),
      )],
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
      )],
      [$SMake::Model::Const::EXTERNAL_TASK,
          SMake::Platform::Generic::InstallTranslator->new(),
      ],
      [$SMake::Model::Const::CLEAN_TASK,
          SMake::Platform::Generic::CleanTranslator->new(),
      ],
      [$SMake::Model::Const::SERVICE_TASK,
          SMake::Platform::Generic::ServiceTranslator->new(),
      ],
  );
  
  # -- source scanners
  $this->getScanner()->appendScanners(
      SMake::ToolChain::Scanner::HdrScanner->new('.*', '.*', '[.](c|cpp|h)$'),
  );
  
  # -- resource filters
  $this->getResourceFilter()->appendFilters(
      SMake::ToolChain::ResourceFilter::SysLocation->new("/usr/include"),
      SMake::ToolChain::ResourceFilter::SysLocation->new("/usr/include/c++/4.6.3"),
  );
  
  return $this;
}

return 1;
