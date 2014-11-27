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

# Shell instruction - the instruction executes a shell command
package SMake::Executor::Instruction::Shell;

use SMake::Executor::Instruction::Instruction;

@ISA = qw(SMake::Executor::Instruction::Instruction);

# Create new shell instruction
#
# Usage: new($command?)
sub new {
  my ($class, $command) = @_;
  my $this = bless(SMake::Executor::Instruction::Instruction->new(), $class);
  if(defined($command)) {
    $this->{command} = $command;
  }
  else {
    $this->{command} = "";
  }
  $this->{capture} = 1;
  return $this;
}

# Create new shell instruction
#
# Usage: newInstruction($group, $command, $capture)
sub newInstruction {
  my ($class, $group, $command, $capture) = @_;
  my $this = bless(SMake::Executor::Instruction::Instruction->new(), $class);
  $this->{group} = $group;
  $this->{command} = $command;
  $this->{capture} = $capture;
  return $this;
}

# Get the shell command
sub getCommand {
  my ($this) = @_;
  return $this->{command};
}

# Append a text to the shell command
#
# Usage: appendToCommand($text)
sub appendToCommand {
  my ($this, $text) = @_;
  $this->{command} .= $text;
}

# Set the shell command
#
# Usage: setCommand($command)
sub setCommand {
  my ($this, $command) = @_;
  $this->{command} = $command;
}

sub execute {
  my ($this, $context, $taskaddress, $wdir) = @_;
  
  # -- get status of running command
  if(defined($this->{jobid})) {
    my $status = $context->getRunner()->getStatus($context, $this->{jobid});
    return $SMake::Executor::Instruction::Instruction::WAIT if(!defined($status));
    
    # -- TODO: report output of the command
    print $status->[1];
    
    if($status->[0]) {
      return $SMake::Executor::Instruction::Instruction::NEXT;
    }
    else {
      print "error\n";
      return $SMake::Executor::Instruction::Instruction::ERROR;
    }
  }

  # -- execute the command
  $this->{jobid} = $context->getRunner()->prepareCommand(
      $context, $this->{group}, $this->{command}, $wdir, $this->{capture});
  return $SMake::Executor::Instruction::Instruction::WAIT;
}

return 1;
