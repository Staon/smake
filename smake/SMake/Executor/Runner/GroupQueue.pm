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

# A queue of command records with possibility of grouping
package SMake::Executor::Runner::GroupQueue;

# Create new queue
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless({
    queue => [],
    groups => {},
    active => {},
  }, $class);
  return $this;
}

# -- push a job record
#
# Usage: pushRecord($group, $record)
#    group .... name of task group. It can be undef => task is not grouped
#    $record .. the task record
sub pushRecord {
  my ($this, $group, $record) = @_;
  push @{$this->{queue}}, [$group, $record];
}

# Activate next task
#
# The method get next ready task and blocks its group
#
# Usage: activateJob()
# Returns: the record
sub activateJob {
  my ($this) = @_;
  
  # -- search first ready job
  my @pending = ();
  my $rec = shift @{$this->{queue}};
  while(defined($rec)) {
    if(defined($rec->[0]) && defined($this->{groups}->{$rec->[0]})) {
      # -- the group is active
      push @pending, $rec;
    }
    else {
      # -- the job is ready
      if(defined($rec->[0])) {
        $this->{groups}->{$rec->[0]} = 1;
      }
      last;
    }
    $rec = shift @{$this->{queue}};
  }
  
  # -- append blocked jobs back to the queue
  push @{$this->{queue}}, @pending;
  
  if(defined($rec)) {
    return $rec->[1];
  }
  else {
    return $rec;
  }
}

# Unblock a group (jobs from the group now can be run)
#
# Usage: unblockGroup($group)
#    group ..... name of the group
sub unblockGroup {
  my ($this, $group) = @_;
  
  if(defined($group)) {
    delete $this->{groups}->{$group};
  }
}

return 1;
