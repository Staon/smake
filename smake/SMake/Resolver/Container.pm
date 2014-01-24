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

# Generic container resolver
package SMake::Resolver::Container;

use SMake::Resolver::Resolver;

@ISA = qw(SMake::Resolver::Resolver);

use SMake::Utils::Abstract;

# Create new container resolver
#
# Usage: new($resolver*)
sub new {
  my $class = shift;
  my $this = bless(SMake::Resolver::Resolver->new(), $class);
  $this->{list} = [@_];
  return $this;
}

# Append new resolver(s)
#
# Usage: appendResolver($resolver*)
sub appendResolver {
  my $this = shift;
  push @{$this->{list}}, @_;
}

sub resolveResource {
  my ($this, $context, $queue, $resource) = @_;
  
  my $status = 0;
  my $stop = 0;
  foreach my $resolver (@{$this->{list}}) {
    ($status, $stop) = $this->resolvePartial(
        $context, $resolver, $queue, $resource, $status);
    last if($stop);
  }
  return $status;
}

# Resolve a resource through a child resolver
#
# Usage: resolvePartial($context, $resolver, $queue, $resource, $status)
#    context ..... parser context
#    resolver .... the child resolver
#    queue ....... resource queue
#    resource .... the resource
#    status ...... current return value of the container resolver
# Returns: ($status, $stop)
#    status ...... new return value of the container resolver
#    stop ........ if it's true, the container resolver stops work
sub resolvePartial {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
