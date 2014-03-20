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

use SMake::Constructor::Generic;
use SMake::Constructor::MainResource;
use SMake::Data::Address;
use SMake::Data::Path;
use SMake::Executor::Context;
use SMake::Executor::Executor;
use SMake::Mangler::Mangler;
use SMake::Model::DeciderBox;
use SMake::Model::DeciderTime;
use SMake::Parser::Context;
use SMake::Parser::Parser;
use SMake::Parser::Version;
use SMake::Parser::VersionRequest;
use SMake::Reporter::Reporter;
use SMake::Reporter::TargetConsole;
use SMake::Repository::Repository;
use SMake::Resolver::Chain;
use SMake::Resolver::Compile;
use SMake::Resolver::Dependency;
use SMake::Resolver::Link;
use SMake::Storage::File::Storage;
use SMake::ToolChain::ToolChain;
use SMake::Utils::Dirutils;

local $SIG{__WARN__} = sub { die @_ };

# -- reporter
my $reporter = SMake::Reporter::Reporter->new();
$reporter->addTarget(SMake::Reporter::TargetConsole->new(1, 5, ".*"));

# -- file change decider
my $decider = SMake::Model::DeciderBox->new("timestamp");
$decider->registerDecider("timestamp", SMake::Model::DeciderTime->new());

# -- file storage
my $reppath = $ENV{'SMAKE_REPOSITORY'};
my $storage = SMake::Storage::File::Storage->new($reppath);

# -- repository
my $repository = SMake::Repository::Repository->new(undef, $storage);

# -- toolchain
my $mangler = SMake::Mangler::Mangler->new();
my $toolchain = SMake::ToolChain::ToolChain->new(undef, $mangler);
# ---- library artifact
my $resolver = SMake::Resolver::Chain->new(
    SMake::Resolver::Compile->new('.*', '[.]cpp$', 'Dir() . Name() . ".o"'),
    SMake::Resolver::Link->new('.*', '[.]o$', "static_lib"));
my $constructor = SMake::Constructor::Generic->new(
  $resolver, [
    SMake::Constructor::MainResource->new(
        "static_lib", 'Dir() . Name() . ".a"', "liblink", "lib", {}),
  ]);
$toolchain->registerConstructor("lib", $constructor);
# ---- binary artifact
$resolver = SMake::Resolver::Chain->new(
    SMake::Resolver::Compile->new('.*', '[.]cpp$', 'Dir() . Name() . ".o"'),
    SMake::Resolver::Link->new('.*', '[.]o$', "binary"),
    SMake::Resolver::Dependency->new('^link$', "binary"));
$constructor = SMake::Constructor::Generic->new(
  $resolver, [
    SMake::Constructor::MainResource->new(
        "binary", 'Dir() . Name()', "binlink", "bin", {}),
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
my $executor = SMake::Executor::Executor->new();
my $execcontext = SMake::Executor::Context->new($reporter, $repository);
$executor->executeRoots(
    $execcontext,
    [
      SMake::Data::Address->new("Haha", "hello", "binlink"),
    ]);

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
