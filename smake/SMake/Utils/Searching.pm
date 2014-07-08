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
    my $project = $resource->getProject();
    my $resolved = $project->searchResource(
        "^" . quotemeta($SMake::Model::Const::SOURCE_RESOURCE) . "|"
            . quotemeta($SMake::Model::Const::PRODUCT_RESOURCE) . "\$",
        $resource->getName()->removePrefix(1));
    return (1, $resolved, 1) if(defined($resolved));
  }
  
  # -- search table of public resources
  my $prjlist = $context->getRepository()->searchPublicResource(
      SMake::Model::Resource::createKeyTuple(
          $SMake::Model::Const::PUBLISH_RESOURCE, $resource->getName()));
  if(defined($prjlist)) {
  	# -- TODO: select appropriate project
    my $project = $context->getVisibility()->getProject(
        $context, $subsystem, $prjlist->[0]->[0]);
    
    # -- search public resource in the project
    my $resolved = $project->searchResource(
        "^" . quotemeta($SMake::Model::Const::PUBLISH_RESOURCE) . "\$",
        $resource->getName());
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
# Returns: \@list of external resources
sub externalTransitiveClosure {
  my ($context, $subsystem, $resource) = @_;

  my $list = [];
  my @queue = ($resource);
  
  # -- append the root
  my %extmap = ();
  
  while($#queue >= 0) {
    my $current = shift(@queue);
    if(!defined($extmap{$current->getName()->asString()})) {
      # -- not processed yet
      my ($found, $resolved, $local) = resolveExternal($context, $subsystem, $current);
      if(!$found) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "external resource '%s' cannot be resolved!",
            $current->getName()->asString());
      }
      if(defined($resolved)) {
        # -- append to the return list
        push @$list, $resolved;
        
        # -- search its external resources
        my $task = $resolved->getTask();
        my $srctasks = $task->getSources();
        foreach my $src (@$srctasks) {
          if($src->getType() eq $SMake::Model::Const::EXTERNAL_RESOURCE) {
            push @queue, $src;
          }
        }
      }
    }
  }

  return $list;  
}

return 1;
