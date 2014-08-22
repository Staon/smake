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

# Resource filter resolver
package SMake::ToolChain::Resolver::Filter;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Model::Const;
use SMake::ToolChain::Constructor::Constructor;

# Create new resolver
#
# Usage: new($type, $file, $resolver)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    resolver .. slave resolver
sub new {
  my ($class, $type, $file, $resolver) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{resolver} = $resolver;
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  return $this->{resolver}->resolveResource($context, $queue, $resource);
}

return 1;
