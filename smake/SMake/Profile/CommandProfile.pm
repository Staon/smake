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

# A profile which modifies logical commands
package SMake::Profile::CommandProfile;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

use SMake::Utils::Abstract;

# Create new command profile
#
# Usage: new($cmdmask)
#    cmdmask ..... a regular expression of command type (name of the root node)
sub new {
  my ($class, $cmdmask) = @_;
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{cmdmask} = $cmdmask;
  return $this;
}

sub isExecutionProfile {
  my ($this, $context) = @_;
  return 1;
}

sub modifyCommand {
  my ($this, $context, $command, $task) = @_;
 
  if($command->getName() =~ /^$this->{cmdmask}$/) {
    return $this->doJob($context, $command, $task);
  }
  else {
    return $command;
  }
}

# Modify logical command which matches the command mask
#
# Usage: doJob($context, $command, $task)
#    context .... executor context
#    command .... the logical command
#    task ....... a task object which the command is attached to
# Returns: modified logical command
sub doJob {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
