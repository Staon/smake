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

# Generic configuration profile
#
# This is a generic ancestor of profiles which are configured inside configuration
# file. Currently only colliding profiles are handled.
package SMake::Model::ProfileCfg;

use SMake::Model::Profile;

@ISA = qw(SMake::Model::Profile);

# Create new profile
#
# Usage: new($name, \%colliding)
#    name ........ name of the profile
#    colliding ... list of names of colliding profiles
sub new {
  my ($class, $name, $colliding) = @_;
  my $this = bless(SMake::Model::Profile->new($name), $class);
  if(defined($colliding)) {
  	$this->{colliding} = $colliding;
  }
  else {
  	$this->{colliding} = {};
  }
  return $this;
}

sub appendToList {
  my ($this, $profilelist) = @_;
  $profilelist->removeColliding($this->{colliding});
  $profilelist->appendProfile($this);
}

return 1;
 