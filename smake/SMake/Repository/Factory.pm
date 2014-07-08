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

# Creator of repositories according to the SMAKE_REPOSITORY variable
package SMake::Repository::Factory;

use File::Spec;
use SMake::Repository::Default;
use SMake::Utils::Evaluate;
use SMake::Utils::Utils;

$SUBSYSTEM = "repository";
$CONSTRUCTION_FILE = "construct";

sub executeConstructionFile {
  my ($reporter, $file, $parent, $dir) = @_;
  
  my $result = {};
  my $context = {
  	reporter => $reporter,
    parent => $parent,
    dir => $dir,
    Repository => sub {
        $result->{result} = $_[1];
    }
  };
  my $msg = SMake::Utils::Evaluate::evaluateSpecFile($file, $context);
  if(defined($msg)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SUBSYSTEM,
        "cannot execute construction file '%s': %s!",
        $file,
        $msg);
  }
  
  my $repository = $result->{result};
  if(!defined($repository)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SUBSYSTEM,
        "wrong configuration file '%s', repository is not created!",
        $file);
  }
  
  return $repository;
}

# Construct repositories
#
# Usage: createRepositories($reporter, \@dirs)
#    reporter .. logging reporter
#    dirs ...... list of repository paths (strings)
# Returns: the top repository
sub createRepositories {
  my ($reporter, $dirs) = @_;
  
  my $repository = undef;
  foreach my $dir (reverse @$dirs) {
  	# -- check existence of the repository directory
    if(! -d $dir) {
      SMake::Utils::Utils::dieReport(
          $reporter,
          $SUBSYSTEM,
          "repository path '%s' is not any existent directory!",
          $dir);
    }
    
    # -- search for repository construction file
    my $construction = File::Spec->catfile($dir, $CONSTRUCTION_FILE);
    if(-f $construction) {
      $repository = executeConstructionFile(
          $reporter, $construction, $repository, $dir);
    }
    else {
      # -- use default repository
      $repository = SMake::Repository::Default::create($repository, $dir);
    }
  }
  
  if(!defined($repository)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SUBSYSTEM,
        "no one repository is configured!");
  }
  return $repository;
}

# Create repositories according to the environment variable
#
# Usage: createRepositoriesVar($reporter, $value)
#    reporter .... logging reporter
#    value ....... content of the environment variable
# Returns: the top repository
sub createRepositoriesVar {
  my ($reporter, $value) = @_;
  
  my @dirs = split(/:/, $value);
  return createRepositories($reporter, \@dirs);
}

return 1;
