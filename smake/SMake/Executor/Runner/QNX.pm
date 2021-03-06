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

# QNX4 sequential runner
package SMake::Executor::Runner::QNX;

use SMake::Executor::Runner::SequentialBase;

@ISA = qw(SMake::Executor::Runner::SequentialBase);

use QNX4;

# Create new sequential runner
sub new {
  my ($class) = @_;
  return bless(SMake::Executor::Runner::SequentialBase->new(), $class);
}

sub runBlocking {
  my ($this, $context, $command, $capture) = @_;

  if($capture) {
    my $output = QNX4::backticks_keepalive(
        "$command 2>&1", 15000, " ========= SMAKE HEARTBEAT ========= \n");
    if(!defined($output)) {
      return -1, "";
    }
    else {
      return $?, $output;
    }
  }
  else {
    system($command);
    return $?, "";
  }
}

return 1;
