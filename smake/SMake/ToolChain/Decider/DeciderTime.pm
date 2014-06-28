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

# Decider based on file's time stamps
package SMake::ToolChain::Decider::DeciderTime;

use File::stat;
use SMake::ToolChain::Decider::Decider;

@ISA = qw(SMake::ToolChain::Decider::Decider);

# Create new decider
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::ToolChain::Decider::Decider->new(), $class);
}

sub getStamp {
  my ($this, $path) = @_;
  
  my $st = stat($path) or die "unknown file '$path'";
  return $st->mtime;
}

return 1;
