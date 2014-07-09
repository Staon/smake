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

# Table command translator - a table of translators which are selected by
# task types.
package SMake::Executor::Translator::Table;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new translator
#
# Usage: new([$tasktype, $translator]*)
#    tasktype ..... task type
#    translator ... a translator which is used if the task is of the appropriate type
sub new {
  my $class = shift;
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{records} = {};
  $this->appendRecords(@_);
  return $this;
}

# Append new translation records
#
# Usage: appendRecords([$tasktype, $translator]*)
#    tasktype ..... task type
#    translator ... a translator which is used if the task is of the appropriate type
sub appendRecords {
  my $this = shift;
  for my $record (@_) {
    $this->{records}->{$record->[0]} = $record->[1];
  }
}

sub translate {
  my ($this, $context, $task, $command, $wd) = @_;

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
  
  # -- execute the translator
  return $record->translate($context, $task, $command, $wd);
}

return 1;
