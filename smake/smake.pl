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

use Carp;
use SMake::Data::Address;
use SMake::Data::Path;
use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Empty;
use SMake::Executor::Builder::Group;
use SMake::Executor::Const;
use SMake::Executor::Context;
use SMake::Executor::Executor;
use SMake::Executor::Instruction::CheckMarks;
use SMake::Executor::Instruction::StoreMarks;
use SMake::Executor::Runner::Sequential;
use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::Instruction;
use SMake::Executor::Translator::Select;
use SMake::Executor::Translator::Sequence;
use SMake::Executor::Translator::Table;
use SMake::Model::Const;
use SMake::Parser::Context;
use SMake::Parser::Parser;
use SMake::Parser::Version;
use SMake::Parser::VersionRequest;
use SMake::Reporter::Reporter;
use SMake::Reporter::TargetConsole;
use SMake::Repository::Repository;
use SMake::Storage::File::Storage;
use SMake::ToolChain::Constructor::Generic;
use SMake::ToolChain::Constructor::MainResource;
use SMake::ToolChain::Decider::DeciderBox;
use SMake::ToolChain::Decider::DeciderTime;
use SMake::ToolChain::Mangler::Mangler;
use SMake::ToolChain::Resolver::Chain;
use SMake::ToolChain::Resolver::Compile;
use SMake::ToolChain::Resolver::Dependency;
use SMake::ToolChain::Resolver::Link;
use SMake::ToolChain::Resolver::Publish;
use SMake::ToolChain::ResourceFilter::Chain;
use SMake::ToolChain::ResourceFilter::SysLocation;
use SMake::ToolChain::Scanner::Chain;
use SMake::ToolChain::Scanner::HdrScanner;
use SMake::ToolChain::ToolChain;
use SMake::Utils::Dirutils;

#local $SIG{__DIE__} = sub { Carp::confess(@_); };
local $SIG{__WARN__} = sub { die @_ };

# -- reporter
my $reporter = SMake::Reporter::Reporter->new();
$reporter->addTarget(SMake::Reporter::TargetConsole->new(1, 5, ".*"));

# -- file change decider
my $decider = SMake::ToolChain::Decider::DeciderBox->new(
    SMake::ToolChain::Decider::DeciderTime->new());

# -- file storage
my $reppath = $ENV{'SMAKE_REPOSITORY'};
my $storage = SMake::Storage::File::Storage->new($reppath);

# -- repository
my $repository = SMake::Repository::Repository->new(undef, $storage);

# -- toolchain
my $mangler = SMake::ToolChain::Mangler::Mangler->new();
my $cmdbuilder = SMake::Executor::Builder::Group->new(
    [$SMake::Model::Const::SOURCE_TASK, SMake::Executor::Builder::Empty->new()],
    [$SMake::Model::Const::C_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::CXX_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::LIB_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::BIN_TASK, SMake::Executor::Builder::Compile->new(
        "addResources", "addLibraries")],
    [$SMake::Model::Const::EXTERNAL_TASK, SMake::Executor::Builder::Compile->new()],
);
my $cmdtranslator = SMake::Executor::Translator::Table->new(
    [$SMake::Model::Const::CXX_TASK, SMake::Executor::Translator::Sequence->new(
        SMake::Executor::Translator::Instruction->new(
            SMake::Executor::Instruction::CheckMarks),   
        SMake::Executor::Translator::Compositor->new(
            "cc",
            SMake::Executor::Translator::FileList->new(
                $SMake::Executor::Const::PRODUCT_GROUP, "-c ", "", "-o ", "", "", 0),
            SMake::Executor::Translator::FileList->new(
                $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
        SMake::Executor::Translator::Instruction->new(
            SMake::Executor::Instruction::StoreMarks),
    )],
    [$SMake::Model::Const::LIB_TASK, SMake::Executor::Translator::Sequence->new(
        SMake::Executor::Translator::Instruction->new(
            SMake::Executor::Instruction::CheckMarks),   
        SMake::Executor::Translator::Compositor->new(
            "wlib -b",
            SMake::Executor::Translator::FileList->new(
                $SMake::Executor::Const::PRODUCT_GROUP, "", "", "", "", "", 0),
            SMake::Executor::Translator::FileList->new(
                 $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
        SMake::Executor::Translator::Instruction->new(
            SMake::Executor::Instruction::StoreMarks),
    )],
    [$SMake::Model::Const::BIN_TASK, SMake::Executor::Translator::Sequence->new(
        SMake::Executor::Translator::Instruction->new(
            SMake::Executor::Instruction::CheckMarks),   
        SMake::Executor::Translator::Compositor->new(
            "cc",
            SMake::Executor::Translator::FileList->new(
                $SMake::Executor::Const::PRODUCT_GROUP, "", "", "-o ", "", "", 0),
            SMake::Executor::Translator::FileList->new(
                $SMake::Executor::Const::LIB_GROUP, "", "", "-l", "", " ", 1, 'Name() . "." . Suffix()'),
            SMake::Executor::Translator::FileList->new(
                $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 1)),
        SMake::Executor::Translator::Instruction->new(
            SMake::Executor::Instruction::StoreMarks),
    )],
    [$SMake::Model::Const::EXTERNAL_TASK, SMake::Executor::Translator::Compositor->new(
        "echo",
        SMake::Executor::Translator::FileList->new(
            $SMake::Executor::Const::PRODUCT_GROUP, "", "", "", "", " ", 0),
        SMake::Executor::Translator::FileList->new(
            $SMake::Executor::Const::SOURCE_GROUP, "", "", "", "", " ", 0),
    )],
);
my $runner = SMake::Executor::Runner::Sequential->new();
my $scanner = SMake::ToolChain::Scanner::Chain->new(
    SMake::ToolChain::Scanner::HdrScanner->new('.*', '.*', '[.](c|cpp|h)$'),
);
my $resfilter = SMake::ToolChain::ResourceFilter::Chain->new(
    SMake::ToolChain::ResourceFilter::SysLocation->new("/usr/include"),
    SMake::ToolChain::ResourceFilter::SysLocation->new("/usr/include/c++/4.6.3"),
);
my $toolchain = SMake::ToolChain::ToolChain->new(
    undef, $mangler, $cmdbuilder, $cmdtranslator, $runner, $scanner, $resfilter);
# ---- library artifact
my $resolver = SMake::ToolChain::Resolver::Chain->new(
    SMake::ToolChain::Resolver::Compile->new(
        '.*', '[.]c$', 'Dir() . Name() . ".o"',
        $SMake::Model::Const::COMPILE_STAGE,
        $SMake::Model::Const::C_TASK),
    SMake::ToolChain::Resolver::Compile->new(
        '.*', '[.]cpp$', 'Dir() . Name() . ".o"',
        $SMake::Model::Const::COMPILE_STAGE,
        $SMake::Model::Const::CXX_TASK),
    SMake::ToolChain::Resolver::Publish->new(
        '.*', '[.]h$'),
    SMake::ToolChain::Resolver::Link->new('.*', '[.]o$', "static_lib"));
my $constructor = SMake::ToolChain::Constructor::Generic->new(
  $resolver, [
    SMake::ToolChain::Constructor::MainResource->new(
        $SMake::Model::Const::LIB_MAIN_TYPE,
        'Dir() . Name() . ".lib"',
        $SMake::Model::Const::LIB_STAGE,
        $SMake::Model::Const::LIB_TASK, {}),
  ]);
$toolchain->registerConstructor("lib", $constructor);
# ---- binary artifact
$resolver = SMake::ToolChain::Resolver::Chain->new(
    SMake::ToolChain::Resolver::Compile->new(
        '.*', '[.]cpp$', 'Dir() . Name() . ".o"',
        $SMake::Model::Const::COMPILE_STAGE,
        $SMake::Model::Const::CXX_TASK),
    SMake::ToolChain::Resolver::Link->new('.*', '[.]o$', "binary"),
    SMake::ToolChain::Resolver::Dependency->new('^link$', "binary"));
$constructor = SMake::ToolChain::Constructor::Generic->new(
  $resolver, [
    SMake::ToolChain::Constructor::MainResource->new(
        $SMake::Model::Const::BIN_MAIN_TYPE,
        'Dir() . Name()',
        $SMake::Model::Const::BIN_STAGE,
        $SMake::Model::Const::BIN_TASK, {}),
  ]);
$toolchain->registerConstructor("bin", $constructor);

$repository->setToolChain($toolchain);

# -- parser
my $parser = SMake::Parser::Parser->new();
my $context = SMake::Parser::Context->new($reporter, $decider, $repository);
my $path = SMake::Data::Path->fromSystem(SMake::Utils::Dirutils::getCwd("SMakefile"));

# -- parse SMakefiles
$repository->openTransaction();
$parser -> parse($context, $path);
$repository->commitTransaction();

# -- execute the project
$repository->openTransaction();
my $executor = SMake::Executor::Executor->new();
my $execcontext = SMake::Executor::Context->new($reporter, $decider, $repository);
$executor->executeRoots(
    $execcontext,
    [
      SMake::Data::Address->new("Haha", "hello", "binlink"),
    ]);
$repository->commitTransaction();

$repository -> destroyRepository();

my $verparser = SMake::Parser::VersionRequest->new();
my $version = $verparser->parse("= 3.6.19 ");
print $version->printableString() . "\n"; 

#my $path = SMake::Data::Path->new("foo/foo2", "SMakefile");
#print $path->printableString(), "\n";
#print $path->getDirpath()->getDirpath()->getBasepath()->printableString(), "\n";
#my $path = SMake::Data::Path->fromSystem("home/ondrej");
#$path = $path->joinPaths("ahoj/cau", SMake::Data::Path->new("blbost"), "SMakefile");
#print $path->systemRelative(), "\n";

$path = SMake::Data::Path->new("runtime/lib/ondrart.lib");
$path = $mangler->mangleName($context, 'Name() . "/" . Dir() . "." . Suffix()', $path);
print $path->printableString(), "\n";

exit 0;
