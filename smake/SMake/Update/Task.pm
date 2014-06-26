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

# Updateable task object
package SMake::Update::Task;

use SMake::Update::Timestamp;

# Create new task
#
# Usage: new($context, $stage, $name, $type, $wd, \%args)
#    context ..... parser context
#    stage ....... parent stage
#    name ........ name of the task
#    type ........ type of the task
#    wd .......... task's working directory
#    args ........ task's arguments
sub new {
  my ($class, $context, $stage, $name, $type, $wd, $args) = @_;
  my $this = bless({}, $class);
  
  my $task = $stage->getObject()->getTask($name);
  if(defined($task)) {
    $this->{sources} = {map {$_->hashKey() => 0} @{$task->getSourceNames()}};
  }
  else {
    $task = $stage->getObject()->createTask($name, $type, $wd, $args);
    $this->{sources} = {};
  }
  $this->{targets} = {};
  $this->{stage} = $stage;
  $this->{task} = $task;
  
  return $this;
}

# Update the object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;

  # -- update target resources
  $this->{task}->setTargets([
      map {$_->getObject()} values %{$this->{targets}}]);
  
  # -- update source resources
  my $ts_delete = [];
  foreach my $ts (values %{$this->{sources}}) {
    if($ts) {
      $ts->update($context);
    }
    else {
      push @$ts_delete, $ts->getName();
    }
  }
  $this->{task}->deleteSources($ts_delete);
  
  $this->{sources} = undef;
  $this->{targets} = undef;
  $this->{stage} = undef;
  $this->{task} = undef;
}

# Get model task object
sub getObject {
  my ($this) = @_;
  return $this->{task};
}

# Get name of the task
sub getName {
  my ($this) = @_;
  return $this->{task}->getName();
}

# Get type of the task
sub getType {
  my ($this) = @_;
  return $this->{task}->getType();
}

# Get arguments of the task
#
# The arguments are a hash table with a content which meaning depends on the type
# of the task.
sub getArguments {
  my ($this) = @_;
  return $this->{task}->getArguments();
}

# Get stage which the task belongs to
sub getStage {
  my ($this) = @_;
  return $this->{stage};
}

# Get working path of the task
#
# The path has meaning in the context of the repository
sub getWDPath {
  my ($this) = @_;
  return $this->{task}->getWDPath();
}

# Append source resource
#
# Usage: appendSource($context, $resource)
#    context ..... parser context
#    resource .... the resource object
sub appendSource {
  my ($this, $context, $resource) = @_;
  
  my $ts = SMake::Update::Timestamp->new($context, $this, $resource);
  $this->{sources}->{$resource->getKey()} = $ts;
}

# Append a target resource
#
# Usage: appendTarget($context, $resource)
#    context ..... parser context
#    resource .... the resource object
sub appendTarget {
  my ($this, $context, $resource) = @_;
  $this->{targets}->{$resource->getKey()} = $resource;
}

return 1;
