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

# Generic implemenentation of a reporter object
package SMake::Reporter::Reporter;

# Create new reporter
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    targets => [],
  }, $class);
}

# Append new reporting target
#
# Usage: addTarget($target)
sub addTarget {
  my ($this, $target) = @_;
  push @{$this->{targets}}, $target;
}

# Report a message
#
# Usage: report($level, $type, $subsystem, $message)
#    level ..... message level 0 - 5
#    type ...... type of message (critical, error, warning, info, debug)
#    subsytem .. ID of smake's subsystem (i.e. parser, model etc.)
#    message ... reporting message
sub report {
  my ($this, $level, $type, $subsytem, $message) = @_;
  for my $target (@{$this->{targets}}) {
    $target->report($level, $type, $subsytem, $message);
  }
}

# Report a message (use the printf like formatting sequences)
#
# Usage: report($level, $type, $subsystem, $format, ...)
#    level ..... message level 0 - 5
#    type ...... type of message (critical, error, warning, info, debug)
#    subsytem .. ID of smake's subsystem (i.e. parser, model etc.)
#    format .... formatted message
sub reportf {
  my ($this, $level, $type, $subsystem, $format) = splice(@_, 0, 5);
  my $message = sprintf($format, @_);
  $this->report($level, $type, $subsystem, $message);
}

return 1;
