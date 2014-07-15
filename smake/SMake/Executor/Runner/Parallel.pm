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

# Parallel runner - commands can be run parallel up to specified
# number of processes.
package SMake::Executor::Runner::Parallel;

use SMake::Executor::Runner::Runner;

@ISA = qw(SMake::Executor::Runner::Runner);

use IO::Handle;
use IO::Pipe;
use IO::Select;
use SMake::Executor::Executor;
use SMake::Utils::Chdir;
use SMake::Utils::Utils;

# Create new parallel runner
#
# Usage: new($max)
#    max ..... maximal number of parallel processes
sub new {
  my ($class, $max) = @_;
  my $this = bless(SMake::Executor::Runner::Runner->new(), $class);
  $this->{jobid} = 1;    # -- jobid counter
  $this->{max} = $max;
  $this->{queue} = [];
  $this->{status} = {};
  $this->{handles} = [];
  $this->{read_handles} = IO::Select->new();
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
    delete $this->{status}->{$jobid};
    return [$record->[3], $record->[4]];
  }
  else {
    return undef;
  }
}

sub searchRecord {
  my ($handle, $records) = @_;
  foreach my $record (@$records) {
    return $record if($record->[0] == $handle);
  }
  die "invalid handle";
}

sub finishProcess {
  my ($this, $record) = @_;
  
  my $code = waitpid($record->[1], 0);
  if($code >= 0) {
    $code = (!$?)?1:0;
  }
  else {
    $code = 0;
  }
  $record->[2]->[3] = $code;
  $this->{read_handles}->remove($record->[0]);
  $record->[0]->close();
  $this->{handles} = [grep {$_ != $record} @{$this->{handles}}];
}

sub wait {
  my ($this, $context) = @_;
  
  # -- run new commands if some are scheduled and there is
  #    left capacity
  while($#{$this->{queue}} >= 0 && $#{$this->{handles}} < $this->{max}) {
    my $record = shift @{$this->{queue}};
    print $record->[1] . "\n";
    
    # -- fork current process
    my $pipe = IO::Pipe->new();
    my $pid = fork();
    if($pid) {
      # -- parent
      $pipe->reader();
      
      push @{$this->{handles}}, [$pipe, $pid, $record];
      $this->{read_handles}->add($pipe);
      $pipe->blocking(0);
      $record->[4] = "";
    }
    elsif(defined($pid)) {
      # -- child
      $pipe->writer();
      STDOUT->fdopen($pipe, "w");
      
      # -- prepare current working directory
      my $wd = $record->[2];
      if(defined($wd)) {
        if(!chdir($wd->systemAbsolute())) {
          print "it's not possible to enter directory " . $wd->systemAbsolute();
          exit(-1);
        }
      }
      
      # -- run the command
      my $command = $record->[1];
      exec("$command 2>&1");
    }
    else {
      # -- error
      $record->[3] = 0;
      $record->[4] = "failed fork function!";
      $pipe->close();
    }
  }
  
  # -- select pipe handles
  if($this->{read_handles}->count() > 0) {
    my @ready = $this->{read_handles}->can_read();
    foreach my $handle (@ready) {
      my $record = searchRecord($handle, $this->{handles});
      my $buffer = "";
      my $len = read($handle, $buffer, 1024);
      if(defined($len) && $len > 0) {
        $record->[2]->[4] .= $buffer;
      }
      else {
        $this->finishProcess($record);
      }
    }
  }
}

return 1;