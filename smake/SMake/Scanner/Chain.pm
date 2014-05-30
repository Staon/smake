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

# Chain of responsibility of source scanners
package SMake::Scanner::Chain;

use SMake::Scanner::Scanner;

@ISA = qw(SMake::Scanner::Scanner);

# Create new chain scanner
#
# Usage: new([$type, $res, $scanner]*)
#    type ..... a regular expression mask of resource type
#    mask ..... a regular expression mask of resource name
#    scanner .. a scanner of the resources
sub new {
  my $class = shift;
  my $this = bless(SMake::Scanner::Scanner->new(), $class);
  $this->{scanners} = [];
  $this->appendScanners(@_);
  return $this;
}

# Append new scanners
#
# Usage: appendScanners([$type, $res, $scanner]*)
#    type ..... a regular expression mask of resource type
#    mask ..... a regular expression mask of resource name
#    scanner .. a scanner of the resources
sub appendScanners {
  my $this = shift;
  push @{$this->{scanners}}, @_;
}

# Prepend new scanners
#
# Usage: prependScanners([$type, $res, $task, $scanner]*)
#    type ..... a regular expression mask of resource type
#    mask ..... a regular expression mask of resource name
#    task ..... a regular expression mask of task type
#    scanner .. a scanner of the resources
sub prependScanners {
  my $this = shift;
  unshift @{$this->{scanner}}, @_;
}

sub scanSource {
  my ($this, $context, $queue, $artifact, $resource, $task) = @_;
  
  foreach my $record (@{$this->{scanners}}) {
    if(($resource->getType() =~ /$record->[0]/)
       && ($resource->getRelativePath()->asString() =~ /$record->[1]/)
       && ($task->getType() =~ /$record->[2]/)) {
      $record->[3]->scanSource($context, $queue, $artifact, $resource, $task);
      return;
    }
  }
}

return 1;
