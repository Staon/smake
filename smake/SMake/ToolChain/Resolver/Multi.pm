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

# Multi resolver
#
# The resolver contains list of resolvers. The resource is passed to all
# of them.
package SMake::ToolChain::Resolver::Multi;

use SMake::ToolChain::Resolver::Container;

@ISA = qw(SMake::ToolChain::Resolver::Container);

# Create new multi resolver
#
# Usage: new($resolver*)
sub new {
  my $class = shift;
  return bless(SMake::Resolver::Resolver->new(@_), $class);
}

sub resolvePartial {
  my ($this, $context, $resolver, $queue, $resource, $status) = @_;

  if($resolver->resolveResource($context, $queue, $resource)) {
    return (1, 0);
  }
  else {
    return ($status, 0);
  }
}

sub resolvePartialDep {
  my ($this, $context, $resolver, $dependency, $status) = @_;

  if($resolver->resolveDependency($context, $dependency)) {
    return (1, 0);
  }
  else {
    return ($status, 0);
  }
}

return 1;
