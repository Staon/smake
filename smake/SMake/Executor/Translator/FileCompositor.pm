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

# This object works exactly the same as the command compositor. Only the arguments
# are written into a file. It can be used for construction of too long command
# lines if the utility suuports reading of arguments from a file.
# Note: translated value of the first child is expected to be the filename
package SMake::Executor::Translator::FileCompositor;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

use SMake::Executor::Instruction::File;

# Create new compositor
#
# Usage: new($separator, $translator*)
#    separator ..... separator of items
#    translator .... children translators
sub new {
  my ($class, $separator, @translators) = @_;
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{separator} = $separator;
  $this->{records} = [];
  $this->appendRecords(@translators);
  return $this; 
}

# Append translator records
#
# Usage: appendRecords($translator*)
sub appendRecords {
  my $this = shift;
  push @{$this->{records}}, @_;
}

sub translate {
  my ($this, $context, $task, $command, $wd) = @_;
  
  # -- get file name (first argument)
  my $reccopy = [@{$this->{records}}];
  my $namerec = shift @$reccopy;
  my $nameinstr = $namerec->translate($context, $task, $command, $wd);

  # -- construct the file
  my $retvals;
  foreach my $record (@$reccopy) {
    if(!ref($record)) {
      push @$retvals, $record;
    }
    else {
      my $vals = $record->translate($context, $task, $command, $wd);
      foreach my $instr (@$vals) {
        my $str = $instr->getCommand();
        if($str) {
          push @$retvals, $instr->getCommand();
        }
      }
    }
  }
  
  return [SMake::Executor::Instruction::File->new(
      $nameinstr->[0]->getCommand(),
      $task->getWDPhysicalPath(),
      $this->{separator},
      $retvals)];
}

return 1;
