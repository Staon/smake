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
package SMake::ToolChain::Constructor::Generic;

use SMake::ToolChain::Constructor::Constructor;

@ISA = qw(SMake::ToolChain::Constructor::Constructor);

use SMake::ToolChain::Constructor::Queue;
use SMake::Utils::Utils;

# Create new generic constructor
#
# Usage: new($resolver, $resources)
#    resolver .... resolver object
#    resources ... list of records of main resources
sub new {
  my ($class, $resolver, $resources) = @_;
  my $this = bless(SMake::ToolChain::Constructor::Constructor->new(), $class);
  $this->{resolver} = $resolver;
  $this->{resources} = (defined($resources))?$resources:[];
  
  return $this;
}

sub constructArtifact {
  my ($this, $context, $artifact) = @_;
  
  # -- create main resources
  foreach my $record (@{$this->{resources}}) {
    $record->createMainResource($context, $artifact);
  }
  
  # -- clear pushed resolvers and scanners
  $context->clearScanners();
  $context->clearResolvers();
}

sub resolveResources {
  my ($this, $context, $artifact, $list) = @_;

  # -- push resolver and scanner into the context to allow pushing of artifact dependent
  #    resolvers and scanners
  $context->pushResolver($this->{resolver});
  $context->pushScanner($context->getToolChain()->getScanner());
  
  # -- resolve resources
  my $queue = SMake::ToolChain::Constructor::Queue->new($list);
  for(
      $resource = $queue->getResource();
      defined($resource);
      $resource = $queue->getResource()) {
    if(!$context->resolveResource($queue, $resource)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
          "there is no resource resolver registered for resource '%s'",
          $resource->getName());
    }
  }
  
  # -- clear pushed resolvers and scanners
  $context->clearScanners();
  $context->clearResolvers();
}

sub resolveDependencies {
  my ($this, $context, $artifact, $list) = @_;

  # -- push resolver and into the context to allow pushing of artifact dependent
  #    resolvers
  $context->pushResolver($this->{resolver});
  
  # -- resolve dependency records
  foreach my $dependency (@$list) {
    if(!$context->resolveDependency($dependency)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
          "there is no dependency resolver registered for dependency '%s'",
          $dependency->getDependencyType());
    }
  }
  
  # -- clear pushed resolvers
  $context->clearResolvers();
}

sub finishArtifact {
  my ($this, $context, $artifact) = @_;

  # -- currently nothing to do
}

return 1;
