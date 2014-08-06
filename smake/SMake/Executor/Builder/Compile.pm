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

# Generic compilation builder
#
# The compilation builder is a special container which compose one command
# according to it's composing records.
package SMake::Executor::Builder::Compile;

use SMake::Executor::Builder::Builder;

@ISA = qw(SMake::Executor::Builder::Builder);


# Create new compilation builder
#
# Usage: new($records*)
#    records ... composing records
sub new {
  my ($class, @records) = @_;
  my $this = bless(SMake::Executor::Builder::Builder->new(), $class);
  $this->{records} = [];
  $this->appendRecords(@records);
  return $this;
}

# Append composing records
#
# Usage: appendRecords($records...)
sub appendRecords {
  my ($this, @records) = @_;
  push @{$this->{records}}, @records;
}

sub build {
  my ($this, $context, $task) = @_;
  
  my $command = SMake::Executor::Command::Set->new($task->getType());
  foreach my $record (@{$this->{records}}) {
    $record->compose($context, $task, $command);
  }
  return [$command];
}

return 1;
