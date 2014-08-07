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

# System location. This filter tries existence of the resource at
# specified system directory
package SMake::ToolChain::ResourceFilter::SysLocation;

use SMake::ToolChain::ResourceFilter::Filter;

@ISA = qw(SMake::ToolChain::ResourceFilter::Filter);

use File::Spec;
use SMake::Model::Const;

# Create new system location filter
#
# Usage: new($location, $transtable)
#    location ..... system path (a string) where the filter tries
#                   to find resources
#    transtable ... optional translation table
sub new {
  my ($class, $location, $transtable) = @_;
  my $this = bless(SMake::ToolChain::ResourceFilter::Filter->new(), $class);
  $this->{location} = $location;
  $this->{transtable} = ($transtable)?$transtable:{};
  return $this;
}

sub filterResource {
  my ($this, $context, $resource) = @_;

  if($resource->getLocation() eq $SMake::Model::Const::EXTERNAL_LOCATION) {
    # -- translate resource name
    my $name = $resource->getName()->removePrefix(1)->systemRelative();
    if(defined($this->{transtable}->{$name})) {
      $name = $this->{transtable}->{$name};
    }
    
    # -- check existence of the resource
    if($name ne "") {
      my $path = File::Spec->catfile($this->{location}, $name);
      return 1 if(-f $path);
    }
    else {
      return 1;  # -- ignored resource
    }
  }
  return 0;
}

return 1;
