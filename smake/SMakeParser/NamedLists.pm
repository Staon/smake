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

#  Named lists
package SMakeParser::NamedLists;

# Ctor
sub newNamedLists {
	my $class = $_[0];
	my $this = {
		
	};
	bless $this, $class;
}

#  Append an item into a list
#
#  Usage: appendItem($name, $item)
sub appendItem {
	my $this = $_[0];
	my $list = $_[1];
	my $name = $_[2];
	push @{$this->getList($list)}, $item;
}

#  Get a named list
#
#  Usage: getList($name)
sub getList {
	my $this = $_[0];
	my $name = $_[1];
	
	my $l = $this->{$name};
	if(! defined($l)) {
		$l = [];
		$this->{$name} = $l;
	}
	return $l;
}

return 1;
