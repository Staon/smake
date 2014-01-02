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

# Clean project - the project is known and its specification is parsed
package SMake::Repository::External::ProjectClean;

# Create new dirty project
#
# Usage: new($name, $path, \@descriptions)
#    project ....... name of the project
sub new {
  my ($class, $project) = @_;
  return bless({
  	project => $project,
  }, $class);
}

# Write projects data
#
# Usage: writeData(\*handle)
sub writeData {
  my ($this, $handle) = @_;
  my $project = $this->{project};
  print $handle "Project('" . $project->getName() . "', '" . $project->getPath() . "');\n";
}

return 1;
