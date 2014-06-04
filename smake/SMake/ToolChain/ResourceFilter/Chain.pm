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

# Chain filter. The filter tries a chainof filters until some filters
package SMake::ToolChain::ResourceFilter::Chain;

use SMake::ToolChain::ResourceFilter::Filter;

@ISA = qw(SMake::ToolChain::ResourceFilter::Filter);

# Create new chain filter
#
# Usage: new($filter*)
sub new {
  my $class = shift;
  my $this = bless(SMake::ToolChain::ResourceFilter::Filter->new(), $class);
  $this->{filters} = [];
  $this->appendFilters(@_);
  return $this;
}

# Append filters into the chain
#
# Usage: appendFilters($filter*)
sub appendFilters {
  my $this = shift;
  push @{$this->{filters}}, @_;
}

sub filterResource {
  my ($this, $context, $resource) = @_;
  
  foreach my $filter (@{$this->{filters}}) {
    return 1 if($filter->filterResource($context, $resource));
  }
  return 0;
}

return 1;
