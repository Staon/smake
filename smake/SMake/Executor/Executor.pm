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
  
  my ($project, $artifact, $stage) = $address->getObjects(
      $reporter, $SUBSYSTEM, $repository);
  return $stage->getDependencies($reporter, $SUBSYSTEM);
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
