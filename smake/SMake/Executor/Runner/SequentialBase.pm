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

# Sequential runner - commands are run in one sequencer without any
# paralelization.
package SMake::Executor::Runner::SequentialBase;

use SMake::Executor::Runner::Runner;

@ISA = qw(SMake::Executor::Runner::Runner);

use SMake::Executor::Executor;
use SMake::Utils::Chdir;
use SMake::Utils::Abstract;
use SMake::Utils::Utils;

# Create new sequential runner
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Executor::Runner::Runner->new(), $class);
  $this->{jobid} = 1;    # -- jobid counter
  $this->{queue} = [];
  $this->{status} = {};
  return $this;
}

sub prepareCommand {
  my ($this, $context, $group, $command, $wd, $capture) = @_;
  
  my $jobid = $this->{jobid}++;
  my $record = [$jobid, $command, $wd, $capture, undef, undef];
  push @{$this->{queue}}, $record;
  $this->{status}->{$jobid} = $record;
  
  return $jobid;
}

sub getStatus {
  my ($this, $context, $jobid) = @_;
  
  # -- get job record
  my $record = $this->{status}->{$jobid};
  if(!defined($record)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "invalid jobid %s",
        $jobid . "");
  }

  # -- process job's status
  if(defined($record->[4])) {
    # -- the job already finished
    delete $this->{status}->{$jobid};
    return [$record->[4], $record->[5]];
  }
  else {
    return undef;
  }
}

sub wait {
  my ($this, $context) = @_;
  
  if($#{$this->{queue}} >= 0) {
    my $record = shift @{$this->{queue}};

    # -- prepare current working directory
    my $dirkeeper = SMake::Utils::Chdir->new();
    if(defined($record->[2])) {
      $dirkeeper->pushDir(
          $record->[2]->systemAbsolute(),
          $context->getReporter(),
          $SMake::Executor::Executor::SUBSYSTEM);
    }

    # -- run the command
    my $command = $record->[1];
    print "$command\n";
    my ($code, $output) = $this->runBlocking($context, $command, $record->[3]);
    $record->[5] = $output;
    $record->[4] = (!$code)?1:0;
    
    # -- change current working directory back
    if(defined($record->[2])) {
      $dirkeeper->popDir(
          $context->getReporter(),
          $SMake::Executor::Executor::SUBSYSTEM);
    }
  }
}

# Blocking execution of a command
#
# Usage: runBlocking($context, $command, $capture)
#    context ...... executor context
#    command ...... the command (string)
#    capture ...... if it's true, the output is captured
# Returns: ($code, $output)
#    code ......... command return code
#    output ....... command's output
sub runBlocking {
  SMake::Utils::Abstract::dieAbstract();
}

sub cleanOnError {
  my ($this, $context) = @_;
  
  # -- nothing to do, as there cannot be running another task
}

return 1;
