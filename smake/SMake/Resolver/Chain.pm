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

# Chain resolver
#
# The chain resolver contains a list of resolvers. If a resource is needed
# to be resolved, the resolver search for first resolver, which handles
# the resource.
package SMake::Resolver::Chain;

use SMake::Resolver::Container;

@ISA = qw(SMake::Resolver::Container);

# Create new chain resolver
#
# Usage: new($resolver*)
sub new {
  my $class = shift;
  return bless(SMake::Resolver::Container->new(@_), $class);
}

sub resolvePartial {
  my ($this, $context, $resolver, $scanner, $queue, $resource, $status) = @_;
  
  if($resolver->resolveResource($context, $scanner, $queue, $resource)) {
    return (1, 1);
  }
  else {
    return (0, 0);
  }
}

sub resolvePartialDep {
  my ($this, $context, $resolver, $dependency, $status) = @_;
  
  if($resolver->resolveDependency($context, $dependency)) {
    return (1, 1);
  }
  else {
    return (0, 0);
  }
}

return 1;
