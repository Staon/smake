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
use Getopt::Long;
use SMake::Data::Address;
use SMake::Data::Path;
use SMake::Executor::Context;
use SMake::Executor::Runner::Sequential;
use SMake::InstallArea::StdArea;
use SMake::Parser::Context;
use SMake::Parser::Parser;
use SMake::Parser::Version;
use SMake::Parser::VersionRequest;
use SMake::Parser::Visibility;
use SMake::Platform::Aveco::ToolChain;
use SMake::Platform::GCC::ToolChain;
use SMake::Profile::InstallPaths;
use SMake::Profile::LocalDirs;
use SMake::Profile::Profile;
use SMake::Profile::Stack;
use SMake::Profile::VarProfile;
use SMake::Reporter::Reporter;
use SMake::Reporter::TargetConsole;
use SMake::Repository::Factory;
use SMake::Storage::File::Storage;
use SMake::ToolChain::Decider::DeciderBox;
use SMake::ToolChain::Decider::DeciderTime;
use SMake::Utils::Dirutils;
use SMake::Utils::Searcher;

local $SIG{__DIE__} = sub { Carp::confess(@_); };
local $SIG{__WARN__} = sub { die @_ };

# Parse command line options
my $search = '';
my $force = '';
if(!GetOptions(
    'search' => \$search,
    'force' => \$force)) {
  die "invalid command line optione.";
}
my @stages = @ARGV;

# -- reporter
my $reporter = SMake::Reporter::Reporter->new();
$reporter->addTarget(SMake::Reporter::TargetConsole->new(1, 5, ".*"));

# -- create repositories
my $repository = SMake::Repository::Factory::createRepositoriesVar(
    $reporter, $ENV{'SMAKE_REPOSITORY'});

# -- file change decider
my $decider = SMake::ToolChain::Decider::DeciderBox->new(
    SMake::ToolChain::Decider::DeciderTime->new());

# -- toolchain
my $runner = SMake::Executor::Runner::Sequential->new();
my $toolchain = SMake::Platform::Aveco::ToolChain->new($runner);
#my $toolchain = SMake::Platform::GCC::ToolChain->new($runner);
$repository->setToolChain($toolchain);

# -- profiles
$repository->registerProfile("memtest", SMake::Profile::Profile);
$repository->registerProfile(
    "header",
    SMake::Profile::VarProfile,
    $SMake::Model::Const::VAR_HEADER_DIRECTORY);

# -- configuration profiles
my $profiles = SMake::Profile::Stack->new();
$profiles->appendProfile(SMake::Profile::InstallPaths->new(
    $SMake::Model::Const::CXX_TASK, "header_dirs", $SMake::Model::Const::HEADER_MODULE));
$profiles->appendProfile(SMake::Profile::LocalDirs->new(
    $SMake::Model::Const::CXX_TASK,
    "header_dirs",
    "^" . quotemeta($SMake::Model::Const::HEADER_MODULE . "/"),
    1));
$profiles->appendProfile(SMake::Profile::InstallPaths->new(
    $SMake::Model::Const::BIN_TASK, "lib_dirs", $SMake::Model::Const::LIB_MODULE));

# -- get list of SMakefiles to be parsed
my $paths = [];
if(!$search) {
  # -- local SMakefile
  push @$paths, SMake::Data::Path->fromSystem(SMake::Utils::Dirutils::getCwd("SMakefile"));
}
else {
  # -- SMakefile searching
  my $searcher = SMake::Utils::Searcher->new();
  my $basedir = SMake::Utils::Dirutils::getCwd();
  my $list = $searcher->search($basedir, "SMakefile");
  foreach my $path (@$list) {
    push @$paths, SMake::Data::Path->fromSystem($path);
  }
}

# -- parse the SMakefiles
my $parser = SMake::Parser::Parser->new();
my $visibility = SMake::Parser::Visibility->new();
my $context = SMake::Parser::Context->new(
    $reporter, $decider, $repository, $visibility, $profiles);
foreach my $path (@$paths) {
  $repository->openTransaction();
  $parser -> parse($context, $path);
  $repository->commitTransaction();
}

# -- execute the project
$repository->openTransaction();
my $executor = SMake::Executor::Executor->new($force);
my $installarea = SMake::InstallArea::StdArea->new($SMake::Model::Const::SOURCE_RESOURCE);
my $execcontext = SMake::Executor::Context->new(
    $reporter, $decider, $repository, $visibility, $installarea, $profiles);
foreach my $stage (@stages) {
  my $execlist = $visibility->createRootList($execcontext, "main", ".*", ".*", $stage);
  $executor->executeRoots($execcontext, $execlist);
}
$repository->commitTransaction();

$repository -> destroyRepository();

#my $verparser = SMake::Parser::VersionRequest->new();
#my $version = $verparser->parse("= 3.6.19 ");
#print $version->printableString() . "\n"; 

exit 0;
