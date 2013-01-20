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

package PTest;

# Report a failed assert
#  $1 ... File name
#  $2 ... Line number
sub TEST_REPORT {
	die "Assert at line $_[1] of file $_[0] failed!\n";
}

# True when two lists contains the same text values
sub checkLists {
	# -- size test
	if(@{$_[0]} != @{$_[1]}) { return 0 }
	
	foreach $left (@{$_[0]}) {
		my $found = 0;
		foreach $right (@{$_[1]}) {
			if($left eq $right) {
				$found = 1;
				last;
			}
		}
		if(! $found) { return 0 }
	}
	
	return 1;
}

return 1;
