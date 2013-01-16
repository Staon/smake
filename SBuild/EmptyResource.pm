# Copyright (C) 2013 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is free software: you can redistribute it and/or modify
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

#  Empty resource
#
#  This resource is used as a profile container only when the resource
#  doesn't exist yet.
package SBuild::EmptyResource;

use SBuild::Resource;

@ISA = qw(SBuild::Resource);

#  Ctor
#
#  Usage: newResource($id)
sub newResource {
	my $class = $_[0];
	my $this = SBuild::Resource->newResource($_[1]);
	bless $this, $class;
}



return 1;
