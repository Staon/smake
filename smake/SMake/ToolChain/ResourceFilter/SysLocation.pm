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

# Create new system location filter
#
# Usage: new($location)
#    location ..... system path (a string) where the filter tries
#                   to find resources
sub new {
  my ($class, $location) = @_;
  my $this = bless(SMake::ToolChain::ResourceFilter::Filter->new(), $class);
  $this->{location} = $location;
  return $this;
}

sub filterResource {
  my ($this, $context, $resource) = @_;

  my $resname = $resource->getName()->removePrefix(1);  
  my $path = File::Spec->catfile(
      $this->{location}, $resname->systemRelative());
  if(-f $path) {
    return 1;
  }
  else {
    return 0;
  }
}

return 1;
