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

#  Empty main resource
package SMakeParser::EmptyMainResource;

use SMakeParser::MainResource;

@ISA = qw(SMakeParser::MainResource);

#  Ctor
#
#  Usage: newResource(\%args)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::MainResource->newResource("smake_wrong_resource_name");
	$this->setArguments($_[1]);
	bless $this, $class;
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMap {
	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResource {
	return undef;
} 

return 1;
