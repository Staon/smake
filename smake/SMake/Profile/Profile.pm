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

# Generic profile interface
package SMake::Profile::Profile;

use Data::Dumper;

# Create new profile object
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Dump a content of the profile to be restored by the function ressurect()
sub dumpContent {
  my ($this) = @_;
  
  my $dumper = Data::Dumper->new([$this], [qw(profile)]);
  $dumper->Indent(0);  # -- one line
  $dumper->Purity(1);
  return $dumper->Dump();
}

# (static) ressurect a profile object from a dump string
#
# Usage: ressurect($dump)
#    dump ..... the dump string
# Returns: the profile object
sub ressurect {
  my ($dump) = @_;
  
  local $project;
  my $info = eval $dump;
  if(!defined($info) && (defined($@) && $@ ne "")) {
    die "it's not possible to create profile object!";
  }
  
  return $project;
}

return 1;
