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

# Generic library profile
package SMake::Model::ProfileLib;

use SMake::Model::ProfileCfg;

@ISA = qw(SMake::Model::ProfileCfg);

# Create new library profile
#
# Usage: new($name, \@liblist, \@syslist, \@colliding)
#    name ...... name of the profile
#    liblist ... list of linked projects
#    syslist ... list of system libraries
#    colliding . list of names of colliding profiles
sub new {
  my ($class, $name, $liblist, $syslist, $colliding) = @_;
  my $this = bless(SMake::Model::ProfileCfg->new($name, $colliding), $class);
  $this->{liblist} = $liblist;
  $this->{syslist} = $syslist;
  return $this;
}

return 1;
