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

# Generic interface of deciders. Deciders are objects which detect changes
# of a file. There can be several types: deciders based on time stamps of
# the files, or deciders based on a checksum of the files.
package SMake::ToolChain::Decider::Decider;

use SMake::Utils::Abstract;

# Create new decider
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Get decider stamp of a file
#
# Usage: getStamp($path)
#    path .... path of the file (absolute filesystem path)
# Returns: The stamp (a scalar convertible to string)
# Exceptions: the method dies if the file doesn't exists.
sub getStamp {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
