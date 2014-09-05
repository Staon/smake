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

# Generic runner interface - execution of shell commands
package SMake::Executor::Runner::Runner;

use SMake::Utils::Abstract;

# Create new runner
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Prepare a shell command
#
# Usage: prepareCommand($context, $command, $wd, $capture)
#    context ...... executor context
#    command ...... shell command
#    wd ........... absolute system path of the working directory (a Path object)
#    capture ...... if it's true, the output of the command is captured
# Returns: an identifier of the job
sub prepareCommand {
  SMake::Utils::Abstract::dieAbstract();
}

# Get status of a job
#
# Usage: getStatus($context, $job)
# Returns: undef if the job is running. [$retflag, $output] if the job is finished.
#    The $retflag contains a true value, if the job finished succesfully. The $output
#    contains caught output of the job's command.
sub getStatus {
  SMake::Utils::Abstract::dieAbstract();
}

# Block the process until some job finishes
#
# Usage: wait($context)
sub wait {
  SMake::Utils::Abstract::dieAbstract();
}

# Clean currently running task if the smake stops on an error
#
# Usage: cleanOnError($context)
sub cleanOnError {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
