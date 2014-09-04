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

use SMake::Model::Const;
use SMake::ToolChain::Constructor::Queue;
use SMake::Utils::Utils;

# Create new generic constructor
#
# Usage: new($resolver, $resources, $finishrecs)
#    resolver .... resolver object
#    resources ... list of records of main resources
#    finishrecs .. list of finishing records
sub new {
  my ($class, $resolver, $resources, $finishrecs) = @_;
  my $this = bless(SMake::ToolChain::Constructor::Constructor->new(), $class);
  $this->{resolver} = $resolver;
  $this->{resources} = [];
  $this->{finishrecs} = [];
  $this->{profiles} = [];
  
  $this->appendMainResource(@$resources) if(defined($resources));
  $this->appendFinishRecord(@$finishrecs) if(defined($finishrecs));
  
  return $this;
}

# Append new main resource record
#
# Usage: appendMainResource($resource...)
sub appendMainResource {
  my ($this, @resources) = @_;
  push @{$this->{resources}}, @resources;
}

# Append finish records
#
# Usage: appendFinishRecord($records...);
sub appendFinishRecord {
  my ($this, @finishrecs) = @_;
  push @{$this->{finishrecs}}, @finishrecs;
}

# Append new resolve. The method expects that the resolver of mine is a container
# resolver.
sub appendResolver {
  my ($this, $resolver) = @_;
  $this->{resolver}->appendResolver($resolver);
}

# Append profile(s)
#
# Usage: appendProfile($profile...)
sub appendProfile {
  my ($this, @profiles) = @_;
  push @{$this->{profiles}}, @profiles;
}

sub resolveResourcesQueue {
  my ($this, $context, $artifact, $queue) = @_;
  
  # -- resolve resources
  for(
      $resource = $queue->getResource();
      defined($resource);
      $resource = $queue->getResource()) {
    if(!$context->resolveResource(
        $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM, $queue, $resource)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
          "there is no resource resolver registered for resource '%s'",
          $resource->getName()->asString());
    }
  }
}

sub constructArtifact {
  my ($this, $context, $artifact) = @_;

  # -- push resolver and scanner into the context to allow pushing of artifact dependent
  #    resolvers and scanners
  $context->pushResolver($this->{resolver});
  $context->pushScanner($context->getToolChain()->getScanner());
  
  # -- push the profiles
  $context->getProfiles()->appendProfile(@{$this->{profiles}});
}

sub createMainResources {
  my ($this, $context, $artifact) = @_;

  # -- create main resources
  my $queue = SMake::ToolChain::Constructor::Queue->new([]);
  foreach my $record (@{$this->{resources}}) {
    $record->createMainResource($context, $artifact, $queue);
  }
  $this->resolveResourcesQueue($context, $artifact, $queue);
}

sub resolveResources {
  my ($this, $context, $artifact, $list) = @_;

  my $queue = SMake::ToolChain::Constructor::Queue->new($list);
  $this->resolveResourcesQueue($context, $artifact, $queue);
}

sub resolveDependencies {
  my ($this, $context, $artifact, $list) = @_;

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
}

sub finishArtifact {
  my ($this, $context, $artifact) = @_;

  # -- process the finishing records  
  foreach my $rec (@{$this->{finishrecs}}) {
    $rec->finish($context, $artifact, $this);
  }
}

return 1;
