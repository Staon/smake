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
package SMake::Executor::Runner::Sequential;

use SMake::Executor::Runner::Runner;

@ISA = qw(SMake::Executor::Runner::Runner);

use QNX4;
use SMake::Executor::Executor;
use SMake::Utils::Chdir;
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
  my ($this, $context, $command, $wd) = @_;
  
  my $jobid = $this->{jobid}++;
  my $record = [$jobid, $command, $wd, undef, undef];
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
  if(defined($record->[3])) {
    # -- the job already finished
    $this->{status}->{$jobid} = undef;
    return [$record->[3], $record->[4]];
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
    $record->[4] = QNX4::backticks_keepalive(
        "$command 2>&1", 15000, " ========= SMAKE HEARTBEAT ========= \n");
    $record->[3] = (!$?)?1:0;
    
    # -- change current working directory back
    if(defined($record->[2])) {
      $dirkeeper->popDir(
          $context->getReporter(), $SMake::Executor::Executor::SUBSYSTEM);
    }
  }
}

return 1;
