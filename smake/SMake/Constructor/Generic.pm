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
# Usage: new($resolver, $resources)
#    resolver .... resolver object
#    resources ... list of records of main resources
sub new {
  my ($class, $resolver, $resources) = @_;
  my $this = bless(SMake::Constructor::Constructor->new(), $class);
  $this->{resolver} = $resolver;
  $this->{resources} = (defined($resources))?$resources:[];
  
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
  
  # -- create main resources
  foreach my $record (@{$this->{resources}}) {
    $record->createMainResource($context, $artifact);
  }

  # -- push resolver and scanner into the context to allow pushing of artifact dependent
  #    resolvers and scanners
  $context->pushResolver($this->{resolver});
  $context->pushScanner($context->getToolChain()->getScanner());
  
  # -- resolve resources
  for(
      $resource = $queue->getResource();
      defined($resource);
      $resource = $queue->getResource()) {
    if(!$context->resolveResource($queue, $resource)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Constructor::Constructor::SUBSYSTEM,
          "there is no resource resolver registered for resource '%s'",
          $resource->getName());
    }
  }
  
  # -- resolve dependency records
  my $dependencies = $artifact->getDependencyRecords();
  foreach my $dependency (@$dependencies) {
    if(!$context->resolveDependency($dependency)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Constructor::Constructor::SUBSYSTEM,
          "there is no dependency resolver registered for dependency '%s'",
          $dependency->getDependencyType());
    }
  }
  
  # -- clear pushed resolvers and scanners
  $context->clearScanners();
  $context->clearResolvers();
}

return 1;
