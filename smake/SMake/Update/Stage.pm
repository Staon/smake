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

# Updateable stage object
package SMake::Update::Stage;

use SMake::Update::Task;

# Create new stage object
#
# Usage: new($repository, $artifact, $name)
#    repository ... smake repository
#    artifact ..... parent artifact object
#    name ......... name of the artifact
sub new {
  my ($class, $repository, $artifact, $name) = @_;
  my $this = bless({}, $class);
  
  my $stage = $artifact->getObject()->getStage($name);
  if(defined($stage)) {
  	$this->{tasks} = {map {$_ => 0} @{$stage->getTaskNames()}};
  }
  else {
    $stage = $artifact->getObject()->createStage($name);
    $this->{tasks} = {};
  }
  $this->{artifact} = $artifact;
  $this->{stage} = $stage;
  
  return $this;
}

# Update data of the stage object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;
  
  # -- update tasks
  my $to_delete = [];
  foreach my $task (keys %{$this->{tasks}}) {
    my $object = $this->{tasks}->{$task};
    if($object) {
      $object->update($context);
    }
    else {
      push @$to_delete, $task;
    }
  }
  $this->{stage}->deleteTasks($to_delete);
  
  $this->{tasks} = undef;
  $this->{artifact} = undef;
  $this->{stage} = undef;
}

# Get model stage object
sub getObject {
  my ($this) = @_;
  return $this->{stage};
}

# Get name of the stage
sub getName {
  my ($this) = @_;
  return $this->{stage}->getName();
}

# Get artifact which the stage belongs to
sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

# Get project which the state belongs to
sub getProject {
  my ($this) = @_;
  return $this->getArtifact()->getProject();
}

# Create new task object
#
# Usage: createTask($context, $name, $task, $wd, \%args)
#    context ...... parser context
#    name ......... name of the task
#    task ......... type of the task
#    wd ........... task's working directory
#    args ......... task's arguments
sub createTask {
  my ($this, $context, $name, $task, $wd, $args) = @_;

  my $taskobj = SMake::Update::Task->new(
      $context, $this, $name, $task, $wd, $args);
  $this->{tasks}->{$name} = $taskobj;
  
  return $taskobj;
}

return 1;
