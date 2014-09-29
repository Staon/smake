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

# Generic interface of data dumper
package SMake::Storage::File::Dumper;

use SMake::Utils::Abstract;

# Ctor
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless({}, $class);
  return $this;
}

# Dump a table into a file
#
# Usage: dumpObject($repository, $storage, $filename, $table)
sub dumpObject {
  SMake::Utils::Abstract::dieAbstract();
}

# Load a table
#
# Usage: loadTable($repository, $storage, $filename)
# Returns: the table
sub loadObject {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
