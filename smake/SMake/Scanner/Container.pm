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

# Generic container scanner
package SMake::Scanner::Container;

use SMake::Scanner::Scanner;

@ISA = qw(SMake::Scanner::Scanner);

use SMake::Utils::Abstract;

# Create new container scanner
#
# Usage: new($scanner*)
sub new {
  my $class = shift;
  my $this = bless(SMake::Scanner::Scanner->new(), $class);
  $this->{scanners} = [];
  $this->appendScanners(@_);
  return $this;
}

# Prepend scanners
#
# Usage: prependScanners($scanner*)
sub prependScanners {
  my $this = shift;
  unshift(@{$this->{scanners}}, @_);
}

# Append scanners
#
# Usage: appendScanners($scanner*)
sub appendScanners {
  my $this = shift;
  push @{$this->{scanners}}, @_;
}

sub scanSource {
  my ($this, $context, $queue, $artifact, $resource, $task) = @_;
  
  my $retval = 0;
  foreach my $scanner (@{$this->{scanners}}) {
  	my ($sret, $stop) = $this->processScanner(
  	    $context, $queue, $artifact, $resource, $task, $scanner);
  	$retval = $retval || $sret;
  	return $retval if($stop);
  }
  return $retval;
}

# Scan a source file
#
# Usage: scanSource($context, $queue, $artifact, $resource, $task, $scanner)
#    context ........ parser context
#    queue .......... queue of resources during construction of an artifact
#    artifact ....... resource's artifact
#    resource ....... the scanned resource
#    task ........... a task which the resource is a source for
#    scanner ........ processing scanner
# Returns: ($ret, $stop)
#    ret ............ true if the scanner processed the resource
#    stop ........... true if the container should stop processing of the resource
sub processScanner {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;