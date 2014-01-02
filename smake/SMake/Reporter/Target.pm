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

# Generic reporter target interface
package SMake::Reporter::Target;

use SMake::Utils::Abstract;

# Create new reporter target
#
# Usage: new($level, $types, $subsytem)
#    level ...... maximal reporting level
#    types ...... regular expression to mask message types
#    subsystem .. regex mask of subsystem
sub new {
  my ($class, $level, $types, $subsystem) = @_;
  my $this = bless({
    level => $level,
  }, $class);
  if(!defined($types)) {
    $this->{types} = qr/^(critical|error|warning|info)$/;
  }
  else {
    $this->{types} = qr/$types/;
  }
  if(!defined($subsystem)) {
    $this->{subsystem} = qr/.*/;
  }
  else {
    $this->{subsystem} = qr/$subsystem/;
  }
  
  return $this;
}

# Report a message
#
# Usage: report($level, $type, $subsystem, $message)
#    level ....... message level
#    type ........ type of the message
#    subsystem ... id of the smake's subsystem
#    message ..... the message
sub report {
  my ($this, $level, $type, $subsystem, $message) = @_;
  if($level <= $this->{level} && $type =~ $this->{types} && $subsystem =~ $this->{subsystem}) {
    $this->reportMessage($level, $type, $subsystem, $message);
  }
}

# Report a message
#
# The message is already checked if it matches reporting criterions
#
# Usage: reportMessage($level, $type, $subsystem, $message)
#    level ....... message level
#    type ........ type of the message
#    subsystem ... id of the smake's subsystem
#    message ..... the message
sub reportMessage {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
