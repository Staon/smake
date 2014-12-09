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
use SMake::Model::Dependency;
use SMake::Utils::Masks;

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
      SMake::Utils::Masks::createMask($SMake::Model::Const::PUBLISH_RESOURCE),
      $resource->getName(),
      SMake::Utils::Masks::createMask($SMake::Model::Const::PUBLIC_LOCATION)
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
    if(!defined($project)) {
      die "project '" . $prjlist->[0]->[0] 
          . "' doesn't exist but it's registered for public resource "
          . $resource->getName()->asString() . "!";
    }
    
    # -- search public resource in the project
    my $resolved = $project->searchResource(
        ".*",
        $resource->getName(),
        SMake::Utils::Masks::createMask($SMake::Model::Const::PUBLIC_LOCATION));
    if(!defined($resolved)) {
      die "There is something wrong. The resource "
          . SMake::Model::Resource::createKey(@$keytuple)
          . " was found in the project " . $project->getName() 
          . " but now it cannot be searched in!";
    }
    
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
      $extmap{$current->[0]->getName()->asString()} = 1;

      # -- resolve the external resource
      my ($found, $resolved, $local) = resolveExternal(
          $context, $subsystem, $current->[0]);
      if(!$found) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "external resource '%s' ('%s') cannot be resolved!",
            $current->[0]->getName()->asString(),
            $current->[0]->getStage()->getAddress()->printableString());
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

# Compute transitive closure of an external resource, but resolve only local
# resources (and ignore resources from another projects)
#
# Usage: localTransitiveClosure($context, $subsystem, $resource)
#    context ...... executor context
#    subsystem .... logging subsystem
#    resource ..... the external resources
# Returns: \@list of resources
sub localTransitiveClosure {
  my ($context, $subsystem, $resource) = @_;

  my $list = [];
  my @queue = ($resource);
  my %extmap = ();
  while($#queue >= 0) {
    my $current = shift(@queue);
    if(!defined($extmap{$current->getName()->asString()})) {
      # -- not processed yet
      $extmap{$current->getName()->asString()} = 1;
      
      # -- resolve the external resource
      my ($found, $resolved) = resolveLocal(
          $context, $subsystem, $current);
      if($found) {
        push @$list, $resolved;

        # -- search its external resources
        my $task = $resolved->getTask();
        my $srctasks = $task->getSources();
        foreach my $src (@$srctasks) {
          if($src->getLocation() eq $SMake::Model::Const::EXTERNAL_LOCATION) {
            push @queue, $src;
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

# Resolve a dependency
#
# Usage: resolveDependency($context, $subsystem, $kind, $type, $project, $artifact, ($mainres|$stage)
#    context ....... parser context
#    subsystem ..... logging subsystem
#    kind .......... kind of the dependency
#    type .......... type of the dependency (it has no meaning, but the dependency key tuple can be passed)
#    project ....... name of the project
#    artifact ...... name of the artifact
#    mainres ....... name of the main resource. It can be null for the default main resource or for stage
#                    dependency.
#    stage ......... name of the dependent stage
# Returns: ($project, $artifact, $stage, $resource)
#    $project ..... dependency project
#    $artifact .... dependency artifact
#    $stage ....... dependency stage
#    $resource .... dependency main resource. It can be undef for stage dependency.
sub resolveDependency {
  my ($context, $subsystem, $kind, $type, $prjname, $artname, $restype) = @_;
  
  my $project = $context->getVisibility()->getProject(
      $context, $subsystem, $prjname);
  if(!defined($project)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "unknown dependent project '%s'",
        $prjname);
  }
    
  my $artifact = $project->getArtifact($artname);
  if(!defined($artifact)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "unknown dependent artifact '%s' in the project '%s'",
        $artname,
        $prjname);
  }
  
  my $stage;
  my $resource;
  if($kind eq $SMake::Model::Dependency::RESOURCE_KIND) {
    # -- dependency on a main resource
    if(!defined($restype)) {
      $resource = $artifact->getDefaultMainResource();
    }
    else {
      $resource = $artifact->getMainResource($restype);
    }
    if(!defined($resource)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $subsystem,
          "unknown dependent main resource '%s' of the artifact '%s' in the project '%s'",
          (defined($restype)?$restype:"default"),
          $prjname,
          $artname);
    }
    $stage = $resource->getStage();
  }
  elsif($kind eq $SMake::Model::Dependency::STAGE_KIND) {
    # -- dependency on a stage
    $stage = $artifact->getStage($restype);
    if(!defined($stage)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $subsystem,
          "unknown dependent stage '%s' of the artifact '%s' in the project '%s'",
          $restype,
          $prjname,
          $artname);
    }
  }
  else {
    die "invalid dependency kind";
  }

  return ($project, $artifact, $stage, $resource);
}

# Get the real resource paired with a public resource
#
# Usage: getRealResource($public)
#    public ....... the public resource
sub getRealResource {
  my ($public) = @_;

  # -- get non-external resources
  my $sources = $public->getTask()->getSources();
  my @list = ();
  foreach my $source (@$sources) {
    if($source->getLocation() ne $SMake::Model::Const::EXTERNAL_LOCATION) {
      push @list, $source;
    }
  }

  # -- there must be only one non-external resource paired with the public resource!
  if($#list != 0) {
    die "invalid pairing of a public and a real resource!";
  }
  
  return $list[0];
}

return 1;
