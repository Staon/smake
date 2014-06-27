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

package SMake::Utils::Print;

# Print indentation
#
# Usage: printIndent($handle, $indent)
#    handle ...... output stream handle
#    indent ...... indent level
sub printIndent {
  my ($indent) = @_;
  
  while($indent > 0) {
    print ::HANDLE "  ";
    --$indent;
  }
}

sub printArguments {
  my ($arguments) = @_;
  
  my $first = 1;
  foreach my $arg (keys %$arguments) {
  	if($first) {
  	  $first = 0;
  	}
  	else {
  	  print ::HANDLE ", ";
  	}
    print ::HANDLE $arg . " => " . $arguments->{$arg}
  }
}

return 1;
