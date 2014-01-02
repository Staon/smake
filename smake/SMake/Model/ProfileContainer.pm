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

# A compilation profile which simply combines several another profiles
package SMake::Model::ProfileContainer;

use SMake::Model::ProfileCfg;

@ISA = qw(SMake::Model::ProfileCfg);

# Create new container profile
#
# Usage: new($name, \@profiles, \%colliding)
sub new {
  my ($class, $name, $colliding, $profiles) = @_;
  my $this = bless(SUPER->new($name, $colliding));
  if(defined($profiles)) {
  	$this -> {profiles} = $profiles;
  }
  else {
  	$this -> {profiles} = [];
  }
  return $this;
}

# Append a profile
#
# Usage: appendProfile($profile)
sub appendProfile {
  my ($this, $profile) = @_;
  push @{$this->{profiles}}, $profile;
}

return 1;
