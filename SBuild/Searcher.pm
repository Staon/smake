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

#  Searching of SMakefiles
package SBuild::Searcher;

use File::Spec;

#  Ctor
sub newSearcher {
	my $class = $_[0];
	my $this = {};
	bless $this, $class;
}

#  Search for SMakefiles
#
#  Usage: search(make_file_name)
#  Return: list of directories which contains a SMakefile
sub search {
	my $this = $_[0];
	my $filename = $_[1];
	
	# -- working set
	my @stack = (File::Spec->curdir);
	my $dirlist = [];
	
	while(@stack) {
		my $dir = pop @stack;
		# -- check presence of a SMakefile
		my $smake = File::Spec->catfile($dir, $filename);
		if(-f $smake) {
			# -- append into the list
			push @$dirlist, $dir;
		}
		else {
			# -- try subdirectories
			if(opendir(DIR, $dir)) {
				my @subdirs = grep { /^[^.]/ && -d File::Spec->catdir($dir, $_) } readdir(DIR);
				push @stack, reverse(map {File::Spec->catdir($dir, $_) } @subdirs);
				closedir DIR;
			}
		}
	}
	
	return $dirlist;
}

return 1;
