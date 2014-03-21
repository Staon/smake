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

# Command translator
package SMake::Executor::Translator;

use SMake::Executor::Executor;
use SMake::Utils::Utils;

sub AUTOLOAD {
  my $name = $AUTOLOAD;
  $name =~ s/.*:://;
  if(defined($evaluation_context->{$name}) && ref($evaluation_context->{$name}) eq "CODE") {
    &{$evaluation_context->{$name}}($name, @_);
  }
  else {
    die "Unknown directive '$name'!"
  }
}

sub translate {
  my ($this, $context, $command, $script) = @_;
  
  local *translation_context = {
    context => $context,
    command => $command,
    cmdlist => [],
  };
  local $SIG{__WARN__} = sub { die @_ };
  my $info = eval $script;
  if(!defined($info) && (defined($@) && $@ ne "")) {
    my $message = $@;
    $message =~ s/\n*$//;
    return (undef, $message);
  }
  
  return $translation_context->{cmdlist};
}

# Create new translator
#
# Usage: new([tasktype, [record, ...]]*)
sub new {
  my $class = shift;
  my $this = bless({
    records => {},
  }, $class);
  $this->appendRecords(@_);
  return $this;
}

# Append new translation records
#
# Usage: appendRecords([tasktype, [record, ...]]*)
sub appendRecords {
  my $this = shift;
  for my $record (@_) {
    $this->{records}->{$record->[0]} = $record->[1];
  }
}

# Translate specified abstract command
#
# Usage: translateCommand($context, $command)
# Returns: [list of strings to be executed by the shell]
sub translateCommand {
  my ($this, $context, $command) = @_;

  # -- get translation task  
  my $tasktype = $command->getName();
  my $record = $this->{records}->{$tasktype};
  if(!defined($record)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "there is no registered translator for task type %s",
        $tasktype);
  }
  
  # -- translate the command
  my $retval = [];
  for my $script (@$record) {
    my $cmdlist = $this->translate($context, $command, $script);
    push @$retval, "@$cmdlist";
  }
  
  return $retval;
}

return 1;
