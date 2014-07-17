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

# Generic resolver interface
package SMake::ToolChain::Resolver::Resolver;

use SMake::Profile::List;
use SMake::Utils::Abstract;

# Create new resolver class
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    profiles => SMake::Profile::List->new(),
  }, $class);
}

# Append a profile to the resolver
#
# Usage: appendProfile($profile)
sub appendProfile {
  my ($this, $profile) = @_;
  $this->{profiles}->appendProfile($profile);
}

# Resolve a resource
#
# Usage: resolveResource($context, $queue, $resource)
#    context ..... parser context, project and artifact are valid
#    queue ....... resource queue
#    resource .... resolved resource
# Returns: true if the resource is handled
sub resolveResource {
  my ($this, $context, $queue, $resource) = @_;
  
  # -- push resolver's profiles
  $context->getProfiles()->pushList();
  $context->getProfiles()->appendProfile($this->{profiles});
  
  # -- do the job
  my $retval = $this->doResolveResource($context, $queue, $resource);
  
  # -- pop the profiles
  $context->getProfiles()->popList();
  
  return $retval;
}

# Resolve a resource
#
# Usage: resolveResource($context, $queue, $resource)
#    context ..... parser context, project and artifact are valid
#    queue ....... resource queue
#    resource .... resolved resource
# Returns: true if the resource is handled
sub doResolveResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Resolve a dependency record
#
# Usage: resolveDependency($context, $dependency)
#    context ..... parser context, project and artifact are valid
#    dependency .. the dependency object
# Returns: true if the dependency is handled
sub resolveDependency {
  my ($this, $context, $dependency) = @_;
  
  # -- push resolver's profiles
  $context->getProfiles()->pushList();
  $context->getProfiles()->appendProfile($this->{profiles});
  
  # -- do the job
  my $retval = $this->doResolveDependency($context, $dependency);
  
  # -- pop the profiles
  $context->getProfiles()->popList();
  
  return $retval;
}

# Resolve a dependency record
#
# Usage: resolveDependency($context, $dependency)
#    context ..... parser context, project and artifact are valid
#    dependency .. the dependency object
# Returns: true if the dependency is handled
sub doResolveDependency {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
