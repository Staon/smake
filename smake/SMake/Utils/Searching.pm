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

# Helper functions to search resources and dependencies between projects
package SMake::Utils::Searching;

use SMake::Model::Const;

# Try to resolve an external resource in local project
#
# Usage: resolveLocal($context, $subsystem, $resource)
#    context ...... executor context
#    subsystem .... logging subsystem
#    resource ..... the external resources
# Returns: ($found, $resource)
#    found ........ true if the resource is resolved
#    resource ..... resolved resource. The value is valid only if the found
#                   flag is true. The value can be undef, if the resource shall
#                   be ignored (e.g. typically system headers)
sub resolveLocal {
  my ($context, $subsystem, $resource) = @_;

  my $project = $resource->getProject();
  my $resolved = $project->searchResource(
      '.*',
      $resource->getName(),
      '^' . quotemeta($SMake::Model::Const::SOURCE_LOCATION)
        . '|' . quotemeta($SMake::Model::Const::PRODUCT_LOCATION)
        . '$'
  );
  if(defined($resolved)) {
    return 1, $resolved;
  }
  else {
    return 0, undef;
  }
}

# Resolve external resource
#
# The function searches a resource which matches the external resource
#
# Usage: resolveExternal($context, $subsystem, $resource)
#    context ...... executor context
#    subsystem .... logging subsystem
#    resource ..... the external resources
# Returns: ($found, $resource, $local)
#    found ........ true if the resource is resolved
#    resource ..... resolved resource. The value is valid only if the found
#                   flag is true. The value can be undef, if the resource shall
#                   be ignored (e.g. typically system headers)
#    local ........ resolved resource is local - it's not accessed through
#                   the installation area. The value is valid only if the found
#                   flag is true.
sub resolveExternal {
  my ($context, $subsystem, $resource) = @_;
  
  # -- search in the local project
  {
    my ($found, $resolved) =  resolveLocal($context, $subsystem, $resource);
    return (1, $resolved, 1) if($found);
  }
  
  # -- search table of public resources
  my $keytuple = $resource->getKeyTuple();
  $keytuple->[0] = $SMake::Model::Const::PUBLIC_LOCATION;
  my $prjlist = $context->getRepository()->searchPublicResource(
      $context, $subsystem, $keytuple);
  if(defined($prjlist)) {
  	# -- TODO: select appropriate project
    my $project = $context->getVisibility()->getProject(
        $context, $subsystem, $prjlist->[0]->[0]);
    
    # -- search public resource in the project
    my $resolved = $project->searchResource(
        ".*",
        $resource->getName(),
        '^' . quotemeta($SMake::Model::Const::PUBLIC_LOCATION) . '$');
    if(!defined($resolved)) {
      die "project '" . $prjlist->[0]->[0] 
          . "' doesn't exist but it's registered for public resource "
          . $resource->getName()->asString() . "!";
    }
    
    # -- get origin resource of the public resource
    $resolved = $resolved->getTask()->getSources()->[0];
    
    return (1, $resolved, 0);
  }
  
  # -- filter the resource by the toolchain
  if($context->getToolChain()->getResourceFilter()->filterResource(
      $context, $resource)) {
    return (1, undef, undef);
  }
  
  return (0, undef, undef);
}

# Compute transitive closure of an external resource (all dependent external
# resources)
#
# Usage: externalTransitiveClosure($context, $subsystem, $resource)
#    context ...... executor context
#    subsystem .... logging subsystem
#    resource ..... the external resources
# Returns: \@list of [$external, $resolved, $local]
#    external ..... external resource paired to the resolved resource
#    resolved ..... the resolved resource
#    local ........ local flag (based on the first external resource)
sub externalTransitiveClosure {
  my ($context, $subsystem, $resource) = @_;

  my $list = [];
  my @queue = ([$resource, 1]);
  my %extmap = ();
  while($#queue >= 0) {
    my $current = shift(@queue);
    if(!defined($extmap{$current->[0]->getName()->asString()})) {
      # -- not processed yet
      my ($found, $resolved, $local) = resolveExternal(
          $context, $subsystem, $current->[0]);
      if(!$found) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "external resource '%s' cannot be resolved!",
            $current->[0]->getName()->asString());
      }
      if(defined($resolved)) {
        # -- append to the return list
        my $reslocal = $current->[1] && $local;
        push @$list, [$current->[0], $resolved, $reslocal];
        
        # -- search its external resources
        my $task = $resolved->getTask();
        my $srctasks = $task->getSources();
        foreach my $src (@$srctasks) {
          if($src->getLocation() eq $SMake::Model::Const::EXTERNAL_LOCATION) {
            push @queue, [$src, $reslocal];
          }
        }
      }
    }
  }

  return $list;  
}

# Compute transitive closure of a task dependency
#
# Usage: dependencyTransitiveClosure($context, $subsystem, $dependency)
#    context ...... executor context
#    subsystem .... logging subsystem
#    dependency ... the task dependency
# Returns: \@list of resolved resources. The list can be empty if the
#    dependency is a stage dependency.
sub dependencyTransitiveClosure {
  my ($context, $subsystem, $dependency) = @_;

  my $list = [];  
  my @queue = ($dependency);
  my %depmap = ();
  while($#queue >= 0) {
    my $current = shift(@queue);
    if(!defined($depmap{$current->getKey()})) {
      $depmap{$current->getKey()} = 1;
      if($current->getDependencyKind() eq $SMake::Model::Dependency::RESOURCE_KIND) {
        my ($project, $artifact, $stage, $resource) = $current->getObjects(
            $context, $subsystem);
        push @$list, $resource;
        
        # -- get transitive dependencies
        my $restask = $resource->getTask();
        my $deplist = $restask->getDependencies();
        foreach my $dep (@$deplist) {
          push @queue, $dep;
        }
      }
    }
  }
  
  return $list;
}

# Get first existing main resource from a list
#
# Usage: resolveMainResource($artifact, \@list)
#    artifact .. the searching artifact
#    list ...... list of resources
# Returns: the resource or undef
sub resolveMainResource {
  my ($artifact, $list) = @_;
  
  if(ref($list) ne "ARRAY") {
    $list = [$list];
  }
  foreach my $res (@$list) {
    my $resource = $artifact->getMainResource($res);
    return $resource if(defined($resource));
  }
  return undef;
}

return 1;
