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

# A helper class - it searches for SMakefiles
package SMake::Utils::Searcher;

use File::Spec;

# Create new searcher
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Search for SMakefiles
#
# Usage: search($basedir, $filename)
#    basedir ...... base directory
#    filename ..... name of the specification files
# Returns: \@list
#    list ......... list of directories (string absolute paths)
sub search {
  my ($this, $basedir, $filename) = @_;
    
  # -- working set
  my @stack = ($basedir);
  my $dirlist = [];

  # -- search for files
  while(@stack) {
    my $dir = pop @stack;

    # -- check presence of a SMakefile
    my $smake = File::Spec->catfile($dir, $filename);
    if(-f $smake) {
      # -- append into the return list
      push @$dirlist, $smake;
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
