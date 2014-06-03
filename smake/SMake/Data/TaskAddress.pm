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

# Address of a task
package SMake::Data::TaskAddress;

# Create new address
#
# Usage: new($stageaddress, $taskid
sub new {
  my ($class, $stageaddress, $taskid) = @_;
  return bless({
  	stageaddress => $stageaddress,
  	taskid => $taskid
  }, $class);
}

# Get a string which can be used as a key
sub getKey {
  my ($this) = @_;
  return $this->{stageaddress}->getKey() . "." . $this->{taskid};
}

# Get stage address
sub getStageAddress {
  my ($this) = @_;
  return $this->{stageaddress};
}

# Get project name
sub getProject {
  my ($this) = @_;
  return $this->{stageaddress}->getProject();
}

# Get name of the artifact
sub getArtifact {
  my ($this) = @_;
  return $this->{stageaddress}->getArtifact();
}

# Get name of the stage
sub getStage {
  my ($this) = @_;
  return $this->{stageaddress}->getStage();
}

# Get task identifier
sub getTask() {
  my ($this) = @_;
  return $this->{taskid};
}

# Compare two addresses for equality
sub isEqual {
  my ($this, $address) = @_;
  return $this->{stageaddress}->isEqual($address->getStageAddress())
      && $this->{taskdi} eq $address->getTask();
}

# Get a printable string of the address
sub printableString {
  my ($this) = @_;
  return $this->getKey();
}

# Get model objects addressed by this object
#
# Usage: getObjects($reporter, $subsystem, $repository)
# Returns: ($project, $artifact, $stage, $task)
sub getObjects {
  my ($this, $reporter, $subsystem, $repository) = @_;
  
  my ($project, $artifact, $stage) = $this->{stageaddress}->getObjects(
      $reporter, $subsystem, $repository);
  my $task = $stage->getTask($this->{taskid});
  if(!defined($task)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "there is something wrong, the task %s.%s is not known!",
        $this->{stageaddress}->printableString(),
        $this->{taskid});
  }
  return ($project, $artifact, $stage, $task);
}

return 1;
