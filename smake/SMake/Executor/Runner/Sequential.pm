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

# UNIX shell sequential runner - commands are run in one sequencer without any
# paralelization.
package SMake::Executor::Runner::Sequential;

use SMake::Executor::Runner::SequentialBase;

@ISA = qw(SMake::Executor::Runner::SequentialBase);

# Create new sequential runner
sub new {
  my ($class) = @_;
  return bless(SMake::Executor::Runner::SequentialBase->new(), $class);
}

# Blocking execution of a command
#
# Usage: runBlocking($context, $command)
#    context ...... executor context
#    command ...... the command (string)
# Returns: ($code, $output)
#    code ......... command return code
#    output ....... command's output
sub runBlocking {
  my ($this, $context, $command) = @_;
  
  delete local $SIG{__WARN__};
  my $output = `$command 2>&1`;
  if(!defined($output)) {
    return -1, "";
  }
  else {
    return $?, $output;
  }
}

return 1;
