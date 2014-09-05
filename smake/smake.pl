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
use SMake::Config::Config;
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
use SMake::Reporter::Reporter;
use SMake::Reporter::TargetConsole;
use SMake::Storage::File::Storage;
use SMake::Utils::Dirutils;
use SMake::Utils::Searcher;

#local $SIG{__DIE__} = sub { Carp::confess(@_); };
local $SIG{__WARN__} = sub { die @_ };
$| = 1;      # -- autoflush of the console

# Parse command line options
my $search = '';
my $force = '';
my @compile_profiles = ();
if(!GetOptions(
    'search' => \$search,
    'force' => \$force,
    'profile=s' => \@compile_profiles)) {
  die "invalid command line option.";
}
my @stages = @ARGV;

# -- reporter
my $reporter = SMake::Reporter::Reporter->new();
$reporter->addTarget(SMake::Reporter::TargetConsole->new(1, 5, ".*"));

# -- create repositories and read configuration
my ($repository, $decider, $runner, $profiles) 
    = SMake::Config::Config::constructRepository(
        $reporter, $ENV{'SMAKE_REPOSITORY'}, \@compile_profiles);

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
  $parser -> parse($context, $context->getRepository()->getRepositoryLocation(
      $SMake::Model::Const::SOURCE_LOCATION, $path));
  $repository->commitTransaction();
}

# -- execute the project
$repository->openTransaction();
my $executor = SMake::Executor::Executor->new();
my $execcontext = SMake::Executor::Context->new(
    $reporter, $decider, $runner, $repository, $visibility, $force);
my $rootlist = [];
my $errflag = 0;
while(@stages) {
  my $stage = shift @stages;
  if($stage eq "/") {
    $errflag = $executor->executeRoots($execcontext, $rootlist) || $errflag;
    if($execcontext->forceRun()) {
      last;
    }
    $rootlist = [];
  }
  elsif($stage eq "unreg") {
    $visibility->unregisterProjects($execcontext, "main");
  }
  elsif($stage eq "all") {
    unshift @stages, "liblink", "dlllink", "binlink";
  }
  elsif($stage eq "new") {
    unshift @stages, "clean", "/", "all";
  }
  else {
    my $execlist = $visibility->createRootList($execcontext, "main", ".*", ".*", $stage);
    push @$rootlist, @$execlist;
  }
}
$errflag = $executor->executeRoots($execcontext, $rootlist) || $errflag;
$repository->commitTransaction();

$repository -> destroyRepository();

exit ($errflag)?1:0;
