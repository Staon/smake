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

# Cache of computed timestamp marks
package SMake::Executor::MarkCache::MarkCache;

use SMake::Utils::Abstract;

# Create new cache object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    cache => {},
  }, $class);
}

# Insert new file timestamp mark
#
# Usage: insertMark($path, $mark)
sub insertMark {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a filestamp mark
#
# Usage: getMark($path)
# Returns: the mark or undef
sub getMark {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
