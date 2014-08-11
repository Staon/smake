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

# This filter filters headers in default locations of the gcc compiler
package SMake::Platform::GCC::HeaderFilter;

use SMake::ToolChain::ResourceFilter::Filter;

@ISA = qw(SMake::ToolChain::ResourceFilter::Filter);

use File::Spec;
use SMake::Model::Const;

# Create new system location filter
#
# Usage: new()
sub new {
  my ($class, $location, $transtable) = @_;
  my $this = bless(SMake::ToolChain::ResourceFilter::Filter->new(), $class);
  
  # -- get list of default include paths
  my $text = `echo | gcc -xc++ -E -v - 2>&1 | sed '1,/^#include [<]/ d; /^End of search list/,\$ d'`;
  $this->{locations} = [split(/\s+/, $text)];
  
  return $this;
}

sub filterResource {
  my ($this, $context, $resource) = @_;

  if($resource->getLocation() eq $SMake::Model::Const::EXTERNAL_LOCATION) {
    # -- check existence of the resource
    my $name = $resource->getName()->systemRelative();
    foreach my $location (@{$this->{locations}}) {
      my $path = File::Spec->catfile($location, $name);
      return 1 if(-f $path);
    }
  }
  return 0;
}

return 1;
