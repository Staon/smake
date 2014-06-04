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
# Returns: ($found, $resource)
#    found ........ true if the resource is resolved
#    resource ..... resolved resource. The value is valid only if the found
#                   flag is true. The value can be undef, if the resource shall
#                   be ignored (e.g. typically system headers)
sub resolveExternal {
  my ($context, $subsystem, $resource) = @_;
  
  # -- search in the local project
  my $project = $resource->getProject();
  my $resolved = $project->searchResource(
      "^" . $SMake::Model::Const::SOURCE_RESOURCE . "|"
          . $SMake::Model::Const::PRODUCT_RESOURCE . "\$",
      $resource->getRelativePath());
  return (1, $resolved) if(defined($resolved));
  
  # -- TODO: search in the global table of public resources
  
  # -- filter the resource by the toolchain
  if($context->getToolChain()->getResourceFilter()->filterResource($context, $resource)) {
    return (1, undef);
  }
  
  return (0, undef);
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
    if(!defined($extmap{$current->getPath()->asString()})) {
      # -- not processed yet
      my ($found, $resolved) = resolveExternal($context, $subsystem, $current);
      if(!$found) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "external resource '%s' cannot be resolved!",
            $current->getPath()->asString());
      }
      if(defined($resolved)) {
        # -- search its external resources
        my $task = $resolved->getTask();
        my $srctasks = $task->getSources();
        foreach my $src (@$srctasks) {
          if($src->getType() eq $SMake::Model::Const::EXTERNAL_RESOURCE) {
            push @queue, $src;
          }
        }
        # -- append to the return list
        push @$list, $resolved;
      }
    }
  }

  return $list;  
}

return 1;
