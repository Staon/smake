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

# Executor object - it computes order of commands and run them
package SMake::Executor::Executor;

use SMake::Data::Address;
use SMake::Utils::TopOrder;

$SUBSYSTEM = "executor";

# Get list of children nodes
#
# Usage: getChildren($reporter, $repository, $address)
# Returns: \@list
sub getChildren {
  my ($reporter, $repository, $address) = @_;
  
  # -- get project
  my $project = $repository->getProject($address->getProject());
  if(!defined($project)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SMake::Executor::Executor::SUBSYSTEM,
        "project '%s' is not known", $address->getProject());
  }
  
  # -- get artifact
  my $artifact = $project->getArtifact($address->getArtifact());
  if(!defined($artifact)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SMake::Executor::Executor::SUBSYSTEM,
        "artifact '%s' is not defined in the project '%s'",
        $address->getArtifact(),
        $address->getProject());
  }
  
  # -- get stage
  my $stage = $artifact->getStage($address->getStage());
  if(!defined($stage)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $SMake::Executor::Executor::SUBSYSTEM,
        "stage '%s' is not defined in the artifact '%s' of the project '%s'",
        $address->getStage(),
        $address->getArtifact(),
        $address->getProject());
  }
  
  return $stage->getDependencies();
}

# Create new executor object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Execute commands
#
# Usage: execute($reporter, $repository, \@roots)
sub executeRoots {
  my ($this, $reporter, $repository, $roots) = @_;
  
  my $toporder = SMake::Utils::TopOrder->new(
      sub { return $_[0]->getKey(); },
      sub { return getChildren($reporter, $repository, $_[0]); });
  my ($info, $cyclelist) = $toporder->compute($roots);

  if($info) {
  	my $toplist = $toporder->getLeaves();
  	while(defined($toplist)) {
  	  # -- print the list
  	  foreach my $address (@$toplist) {
  	    print $address->getKey() . " ";
  	  }
  	  print "\n";
  	  
  	  # -- finish objects
  	  foreach my $address (@$toplist) {
  	  	print "finish: " . $address->getKey() . "\n";
  	    $toporder->finishObject($address);
  	  }
  	  
  	  # -- get next objects
  	  $toplist = $toporder->getLeaves();
  	}
  }
  else {
    print "a cycle: ";
    SMake::Data::Address::printAddressList($cyclelist);
  }
  print "\n";
}

return 1;
