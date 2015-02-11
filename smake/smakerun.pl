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
use SMake::Config::Config;
use SMake::Data::Path;
use SMake::Reporter::Reporter;
use SMake::Reporter::TargetConsole;

local $SIG{__DIE__} = sub { Carp::confess(@_); };
local $SIG{__WARN__} = sub { die @_ };
$| = 1;      # -- autoflush of the console

# Parse command line options
my $project = shift @ARGV;
my $artifact = shift @ARGV;
my $resource = shift @ARGV;

# -- reporter
my $reporter = SMake::Reporter::Reporter->new();
$reporter->addTarget(SMake::Reporter::TargetConsole->new(1, 2, ".*"));

# -- create repositories and read configuration
my ($repository, $decider, $runner, $profiles) 
    = SMake::Config::Config::constructRepository(
        $reporter, $ENV{'SMAKE_REPOSITORY'}, []);
$repository->openTransaction();

# -- search for the project
my ($prjobj, $prjlocal) = $repository->getProject($project);
if(!defined($prjobj)) {
  die "The project '$project' is not known!";
}

# -- search for the artifact
my $artobj = $prjobj->getArtifact($artifact);
if(!defined($artobj)) {
  die "The project '$project' doesn't contain any artifact '$artifact'!";
}

# -- search for the resource
my $resobj = $artobj->searchResource('.*', SMake::Data::Path->new($resource), '.*');
if(!defined($resobj)) {
  die "The resource '$resource' cannot be found in the artifact '$artifact' of the project '$project'!";
}

my $path = $resobj->getPhysicalPath();
chdir $path->getDirpath()->systemAbsolute();
exec "./" . $path->getBasename(), @ARGV;
