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

# Generic smake feature profile
package SMake::Profile::Feature;

use SMake::Profile::ArtifactProfile;

@ISA = qw(SMake::Profile::ArtifactProfile);

# Create new feature profile
#
# Usage: new($typemask, $namemask, $name)
sub new {
  my ($class, $typemask, $namemask, $name) = @_;
  
  my $this = bless(SMake::Profile::ArtifactProfile->new($typemask, $namemask), $class);
  $this->{name} = $name;
  return $this;
}

sub doBeginJob {
  my ($this, $context, $subsystem, $artifact) = @_;
  $artifact->createActiveFeature($context, $this->{name});
}

sub doEndJob {
  # -- nothing to do
}

return 1;
