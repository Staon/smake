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

# Generic resource resolver
package SMake::Resolver::Resource;

use SMake::Resolver::Resolver;

@ISA = qw(SMake::Resolver::Resolver);

use SMake::Utils::Abstract;

# Create new resource resolver
#
# Usage: new($type, $res)
#    type .... a regular expression to match type of the resource
#    res ..... a regular expression to match path of the resource (relative path)
sub new {
  my ($class, $type, $res) = @_;
  my $this = bless(SMake::Resolver::Resolver->new(), $class);
  $this->{typemask} = $type;
  $this->{resmask} = $res;
  return $this;
}

sub resolveResource {
  my ($this, $context, $queue, $resource) = @_;
  
  if(($resource->getType() =~ /$this->{typemask}/)
     && ($resource->getName()->asString() =~ /$this->{resmask}/)) {
    $this->doJob($context, $queue, $resource);
    return 1;
  }
  else {
    return 0;
  }
}

sub resolveDependency {
  return 0;
}

# Do the resolver's job
#
# Usage: doJob($context, $resource)
#    context .... parser context
#    queue ...... resource queue
#    resource ... the resource
sub doJob {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
