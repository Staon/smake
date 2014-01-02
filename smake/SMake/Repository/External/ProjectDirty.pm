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

# Dirty project - the project is known, but its specification is not parsed
package SMake::Repository::External::ProjectDirty;

# Create new dirty project
#
# Usage: new($name, $path)
#    name .... name of the project
#    path .... path to the root specification file
sub new {
  my ($class, $name, $path) = @_;
  return bless({
    name => $name,
    path => $path,
  }, $class);
}

# Write projects data
#
# Usage: writeData(\*handle)
sub writeData {
  my ($this, $handle) = @_;
  print $handle "Project('" . $this->{name} . "', '" . $this->{path} . "');\n";
}

return 1;
