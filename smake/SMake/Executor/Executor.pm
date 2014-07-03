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
use SMake::Executor::Stage;
use SMake::Utils::TopOrder;
use SMake::Utils::Utils;

$SUBSYSTEM = "executor";

# Get list of children nodes
#
# Usage: getChildren($context, $address)
# Returns: \@list
sub getChildren {
  my ($context, $address) = @_;
  
  my ($project, $artifact, $stage) = $address->getObjects($context, $SUBSYSTEM);
  return $stage->computeDependencies($context, $SUBSYSTEM);
}

# Create new executor object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

sub appendStageExecutors {
  my ($this, $context, $exlist, $toporder) = @_;
  
  my $toplist = $toporder->getLeaves();
  foreach my $address (@$toplist) {
  	$context->getReporter()->reportf(
  	    2, "info", $SUBSYSTEM, "enter stage %s", $address->printableString());
  	    
    my $stage = SMake::Executor::Stage->new($context, $address);
    push @$exlist, $stage;
  }
}

# Execute commands
#
# Usage: execute($context, \@roots)
sub executeRoots {
  my ($this, $context, $roots) = @_;
  
  # -- compute topological order of the stages
  my $toporder = SMake::Utils::TopOrder->new(
      sub { return $_[0]->getKey(); },
      sub { return getChildren($context, $_[0]); });
  my ($info, $cyclelist) = $toporder->compute($roots);

  # -- execute stages
  if($info) {
  	# -- prepare first stages to be executed
  	my $stagelist = [];
  	$this->appendStageExecutors($context, $stagelist, $toporder);
  	
  	# -- iterate until there is a work
  	while(@$stagelist) {
  	  my $newlist = [];
  	  foreach my $stage (@$stagelist) {
  	    if($stage->execute($context)) {
  	      # -- some work is still to be done
  	      push @$newlist, $stage;
  	    }
  	    else {
  	      # -- the stage is finished
  	      $toporder->finishObject($stage->getAddress());
  	      $context->getReporter()->reportf(
  	          3,
  	          "info",
  	          $SUBSYSTEM,
  	          "leave stage %s",
  	          $stage->getAddress()->printableString());
  	    }
  	  }
  	  
  	  # -- append new prepared stages
  	  $this->appendStageExecutors($context, $newlist, $toporder);
  	  
  	  # -- switch to next loop iteration
  	  $stagelist = $newlist;
  	  
  	  # -- wait for some finished shell job
  	  $context->getRunner()->wait($context);
  	}
  }
  else {
    # -- a cycle in stage dependencies is detected
    $context->getReporter()->reportf(
        1, "critical", $SUBSYSTEM, "a cycle is detected between stage dependencies: ");
    foreach my $address (@$cyclelist) {
      $context->getReporter()->reportf(
        1, "critical", $SUBSYSTEM, "    %s", $address->printableString());
    }
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SUBSYSTEM,
        "stopped, it's not possible to continue in work");
  }
}

return 1;
