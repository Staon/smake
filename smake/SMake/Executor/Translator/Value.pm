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

# Generic value translator
package SMake::Executor::Translator::Value;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

use SMake::Data::Path;
use SMake::Executor::Executor;
use SMake::Executor::Instruction::Shell;
use SMake::Utils::Abstract;
use SMake::Utils::Utils;

# Create new value translator
#
# Usage: new($address, $optional)
#    address .... addres of the value (path or appropriately formatted string)
sub new {
  my ($class, $address, $optional) = @_;
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{address} = SMake::Data::Path->new($address);
  $this->{optional} = $optional;
  return $this;
}

# Get value address (a Path object)
sub getAddress {
  my ($this) = @_;
  return $this->{address};
}

sub translate {
  my ($this, $context, $task, $command, $wd) = @_;
  
  # -- get the value node
  my $value = $command->getNode(
      $context, $SMake::Executor::Executor::SUBSYSTEM, $this->{address});
  if(!defined($value) && !$this->{optional}) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "command doesn't contain value '%s'!",
        $this->{address}->asString());
  }

  # -- translate the value
  my $list = [];
  if(defined($value)) {
    my $cmds = $this->translateValue($context, $task, $command, $wd, $value);
    foreach my $cmd (@$cmds) {
      push @$list, SMake::Executor::Instruction::Shell->new($cmd);
    }
  }
  return $list; 
}

# Translate value node
#
# Usage: translateValue($context, $task, $command, $wd, $value)
#    context ...... executor context
#    task ......... the task
#    command ...... logical command
#    wd ........... absolute physical path of the task's working directory
#    value ........ value node of the logical command
# Return:
#    \@cmds ....... list of shell commands
sub translateValue {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
