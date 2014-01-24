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

# Generic artifact constructor
package SMake::Constructor::Generic;

use SMake::Constructor::Constructor;

@ISA = qw(SMake::Constructor::Constructor);

use SMake::Constructor::Queue;
use SMake::Utils::Utils;

# Create new generic constructor
#
# Usage: new($resolver)
#    resolver .... resolver object
sub new {
  my ($class, $resolver) = @_;
  my $this = bless(SMake::Constructor::Constructor->new(), $class);
  $this->{resolver} = $resolver;
  
  return $this;
}

sub constructArtifact {
  my ($this, $context, $artifact) = @_;
  
  # -- prepare queue of resources to be resolved
  my $queue = SMake::Constructor::Queue->new();
  my $resources = $artifact->getResources();
  foreach my $resource (@$resources) {
    $queue->pushResource($resource);
  }
  
  # -- TODO: create main resources

  # -- resolve resources
  for(
      $resource = $queue->getResource();
      defined($resource);
      $resource = $queue->getResource()) {
    if(!$this->{resolver}->resolveResource($context, $queue, $resource)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Constructor::Constructor::SUBSYSTEM,
          "there is no resource resolver registered for resource '%s'",
          $resource->getName());
    }
  }
}

return 1;
