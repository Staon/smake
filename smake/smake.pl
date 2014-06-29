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
use SMake::Executor::Context;
use SMake::Executor::Runner::Sequential;
use SMake::Parser::Context;
use SMake::Parser::Parser;
use SMake::Parser::Version;
use SMake::Parser::VersionRequest;
use SMake::Platform::Aveco::ToolChain;
use SMake::Platform::GCC::ToolChain;
use SMake::Reporter::Reporter;
use SMake::Reporter::TargetConsole;
use SMake::Repository::Repository;
use SMake::Storage::File::Storage;
use SMake::ToolChain::Decider::DeciderBox;
use SMake::ToolChain::Decider::DeciderTime;
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
my $runner = SMake::Executor::Runner::Sequential->new();
#my $toolchain = SMake::Platform::Aveco::ToolChain->new($runner);
my $toolchain = SMake::Platform::GCC::ToolChain->new($runner);
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

#my $verparser = SMake::Parser::VersionRequest->new();
#my $version = $verparser->parse("= 3.6.19 ");
#print $version->printableString() . "\n"; 

exit 0;
