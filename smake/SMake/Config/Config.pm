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

# SMake configuration
package SMake::Config::Config;

use File::Spec;
use SMake::Config::DefaultToolChain;
use SMake::Executor::Runner::Sequential;
use SMake::Model::Const;
use SMake::Repository::Factory;
use SMake::ToolChain::Decider::DeciderBox;
use SMake::ToolChain::Decider::DeciderTime;
use SMake::Utils::Evaluate;
use SMake::Utils::Utils;

$SUBSYSTEM = "config";

# Parse content of the SMAKE_REPOSITORY and get list of paths
sub getRepositoryPaths {
  my ($repvar) = @_;
  
  # TODO: dynamic searching of repository paths
  return split(/:/, $repvar);
}

sub getProjectPath {
  my ($project) = @_;

  my $prjpath = $project->getPath();
  return $project->getRepository()->getPhysicalLocationString(
      $SMake::Model::Const::SOURCE_RESOURCE, $prjpath);
}

# Prepend repository directories into the perl's include directory list
sub constructPerlInclude {
  my ($cfgprjs) = @_;
  
  foreach my $prj (reverse @$cfgprjs) {
    unshift @INC, File::Spec->catdir(getProjectPath($prj), "perl");
  }
}

# Search for a toolchain
#
# Usage: constructToolChain($reporter, $repository, $cfgprjs)
sub constructToolChain {
  my ($reporter, $repository, $cfgprjs) = @_;
  
  # -- construct list of possible toolchain files
  my $tcpaths = [];
  foreach my $prj (@$cfgprjs) {
    push @$tcpaths, File::Spec->catfile(getProjectPath($prj), "smaketc");
  }
  push @$tcpaths, File::Spec->catfile($ENV{HOME}, ".smaketc");
  push @$tcpaths, File::Spec->catfile("etc", "smaketc");
  
  # -- search for first toolchain specification
  foreach my $tcfile (@$tcpaths) {
    if(-f $tcfile) {
      # -- evaluate the toolchain specification
      my $toolchain = undef;
      my $context = {
        reporter => $reporter,
        ToolChain => sub {
          $toolchain = $_[1];
        },
        RegisterProfile => sub {
          shift;
          $toolchain->registerProfile(@_);
        }
      };
      my $msg = SMake::Utils::Evaluate::evaluateSpecFile($tcfile, $context);
      if(defined($msg)) {
        SMake::Utils::Utils::dieReport(
            $reporter,
            $SUBSYSTEM,
            "cannot execute toolchain file '%s': %s!",
            $tcfile,
            $msg);
      }

      # -- attach the toolchain to the repository
      if(!defined($toolchain)) {
        SMake::Utils::Utils::dieReport(
            $reporter,
            $SUBSYSTEM,
            "wrong toolchain file '%s', toolchain is not created!",
            $file);
      }
      $repository->setToolChain($toolchain);

      return $toolchain;
    }
  }
  
  # -- construct default toolchain
  my $toolchain = SMake::Config::DefaultToolChain::createDefaultToolChain(
      $repository, $profiles);
  $repository->setToolChain($toolchain);
  return $toolchain;
}

# Read configuration files
#
# Usage: readConfiguration($reporter, $repository, $profiles, $cfgprjs)
# Returns: $decider, $runner
sub readConfiguration {
  my ($reporter, $repository, $profiles, $cfgprjs) = @_;

  # -- construct list of possible configuration files
  my $rcpaths = [];
#  push @$rcpaths, File::Spec->catfile("etc", "smakerc");
#  push @$rcpaths, File::Spec->catfile($ENV{HOME}, ".smakerc");
  foreach my $prj (reverse @$cfgprjs) {
    push @$rcpaths, File::Spec->catfile(getProjectPath($prj), "smakerc");
  }

  # -- default values
  my $decider = SMake::ToolChain::Decider::DeciderBox->new(
        SMake::ToolChain::Decider::DeciderTime->new());
  my $runner = SMake::Executor::Runner::Sequential->new();
  
  # -- evaluate configuration files
  my $evalcontext = {
    Decider => sub {
      $decider->setDecider($_[1]);
    },
    Runner => sub {
      $runner = $_[1];
    },
    Profile => sub {
      shift;
      my $profile;
      if(!ref($_[0])) {
        $profile = $repository->getToolChain()->createProfile(@_);
      }
      else {
        $profile = $_[0];
      }
      $profiles->appendProfile($profile);
    },
  };
  foreach my $rcfile (@$rcpaths) {
    if(-f $rcfile) {
      my $msg = SMake::Utils::Evaluate::evaluateSpecFile(
          $rcfile, $evalcontext);
      if(defined($msg)) {
        SMake::Utils::Utils::dieReport(
            $reporter,
            $SUBSYSTEM,
            "cannot execute configuration file '%s': %s!",
            $rcfile,
            $msg);
      }
    }
  }
  
  return $decider, $runner;
}

# Parse specification of command line profiles
sub parseCmdLineProfiles {
  my ($reporter, $toolchain, $profiles, $profspecs) = @_;
  
  foreach my $profspec (@$profspecs) {
    if($profspec =~ /^([^\s\(\)]+)(\((.*)\))?$/) {
      my ($name, $argspec) = ($1, $3);
      my @args;
      if(defined($argspec)) {
        @args = split(/[\s]*[,][\s]*/, $argspec);
      }
      else {
        @args = ();
      }
      
      # -- create the profile
      my $profile = $toolchain->createProfile($name, @args);
      $profiles->appendProfile($profile);
    }
  }
}

# Construct repository according to the configuration
#
# Usage: constructRepository($reporter, $repvar, \@profspecs)
#    reporter ... reporter object
#    repvar ..... content of the SMAKE_REPOSITORY environment variable
#    profspecs .. list of command line profile specifications
# Returns: $repository, $decider, $runner, $profiles
sub constructRepository {
  my ($reporter, $repvar, $profspecs) = @_;

  # -- create the repositories
  my @repdirs = getRepositoryPaths($repvar);
  my $repository = SMake::Repository::Factory::createRepositories(
      $reporter, \@repdirs);

  $repository->openTransaction();

  # -- get list of configuration projects
  my $cfgprjs = $repository->getOverlappedProjects("SMakeConfig");
  
  # -- construct perl include paths
  constructPerlInclude($cfgprjs);
  
  # -- construct the toolchain
  my $profiles = SMake::Profile::Stack->new();
  my $toolchain = constructToolChain($reporter, $repository, $cfgprjs);
  
  # -- read smake configuration
  my ($decider, $runner) = readConfiguration(
      $reporter, $repository, $profiles, $cfgprjs);
      
  # -- append toolchain's profiles
  $toolchain->appendToolChainProfiles($profiles);
  
  # -- append command line profiles
  parseCmdLineProfiles($reporter, $toolchain, $profiles, $profspecs);
  
  $repository->commitTransaction();

  return $repository, $decider, $runner, $profiles;
}

return 1;
