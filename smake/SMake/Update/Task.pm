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

use SMake::Model::Resource;
use SMake::Model::Timestamp;
use SMake::Update::Table;
use SMake::Update::TaskDependency;
use SMake::Update::Timestamp;

# Create new task
#
# Usage: new($context, $stage, $name, $type, $wd, \%args)
#    context ..... parser context
#    stage ....... parent stage
#    name ........ name of the task
#    type ........ type of the task
#    wdtype ...... resource type of working directory
#    wd .......... task's working directory
#    args ........ task's arguments
sub new {
  my ($class, $context, $stage, $name, $type, $wdtype, $wd, $args) = @_;
  my $this = bless({}, $class);
  
  my $task = $stage->getObject()->getTask($name);
  if(defined($task)) {
    $task->update($type, $wdtype, $wd, $args);
    $this->{targets} = SMake::Update::Table->new(
        \&SMake::Model::Timestamp::createKey,
        $task->getTargetKeys());
    $this->{sources} = SMake::Update::Table->new(
        \&SMake::Model::Timestamp::createKey,
        $task->getSourceKeys());
    $this->{dependencies} = SMake::Update::Table->new(
        \&SMake::Model::TaskDependency::createKey,
        $task->getDependencyKeys());
  }
  else {
    $task = $stage->getObject()->createTask($name, $type, $wdtype, $wd, $args);
    $this->{targets} = SMake::Update::Table->new(
        \&SMake::Model::Timestamp::createKey, []);
    $this->{sources} = SMake::Update::Table->new(
        \&SMake::Model::Timestamp::createKey, []);
    $this->{dependencies} = SMake::Update::Table->new(
        \&SMake::Model::TaskDependency::createKey, []);
  }
  $this->{stage} = $stage;
  $this->{task} = $task;
  $this->{profiles} = [];
  $this->{force_run} = $task->isForceRun();
  
  return $this;
}

# Update the object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;

  # -- update target resources
  my ($tg_delete, $tg_changed) = $this->{targets}->update($context);
  $this->{task}->deleteTargets($tg_delete);
  
  # -- update source resources:
  my ($ts_delete, $ts_changed) = $this->{sources}->update($context);
  $this->{task}->deleteSources($ts_delete);
  
  # -- update task dependencies
  my ($dep_delete, $dep_changed) = $this->{dependencies}->update($context);
  $this->{task}->deleteDependencies($dep_delete);
  
  # -- update profiles
  my $old_profiles = $this->{task}->getProfiles();
  my $prof_changed = 0;
  if($#$old_profiles != $#{$this->{profiles}}) {
    $prof_changed = 1;
  }
  else {
    for(my $i = 0; $i <= $#$old_profiles; ++$i) {
      if($old_profiles->[$i] ne $this->{profiles}->[$i]) {
        $prof_changed = 1;
        last;
      }
    }
  }
  $this->{task}->setProfiles($this->{profiles});

  $this->{task}->setForceRun($this->{force_run} || $ts_changed || $tg_changed || $prof_changed);
  
  $this->{sources} = undef;
  $this->{targets} = undef;
  $this->{dependencies} = undef;
  $this->{stage} = undef;
  $this->{task} = undef;
}

# Get model task object
sub getObject {
  my ($this) = @_;
  return $this->{task};
}

# Get key tuple
sub getKeyTuple {
  my ($this) = @_;
  return $this->{task}->getKeyTuple();
}

# Get string key
sub getKey {
  my ($this) = @_;
  return $this->{task}->getKey();
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

# Get type of the working directory resource
sub getWDType {
  my ($this) = @_;
  return $this->{task}->getWDType();
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

  my $ts = SMake::Update::Timestamp->newSource($context, $this, $resource);
  $this->{sources}->addItem($ts);
}

# Get list of source resources
#
# Usage: getSources()
# Returns: \@list
sub getSources {
  my ($this) = @_;
  return [map { $_->getResource() } @{$this->{sources}->getItems()}];
}

# Append a target resource
#
# Usage: appendTarget($context, $resource)
#    context ..... parser context
#    resource .... the resource object
sub appendTarget {
  my ($this, $context, $resource) = @_;
  
  my $tg = SMake::Update::Timestamp->newTarget($context, $this, $resource);
  $this->{targets}->addItem($tg);
}

# Append an external dependency
#
# Usage: appendDependency($context, $dep, $instmodule)
#    context ...... parser context
#    dep .......... the dependency object
#    instmodule ... installation module
sub appendDependency {
  my ($this, $context, $dep, $instmodule) = @_;
  
  my $taskdep = SMake::Update::TaskDependency->new(
      $context, $this, $dep, $instmodule);
  $this->{dependencies}->addItem($taskdep);
}

# Create and append new task's profile
#
# Usage: appendProfile($context, $dump)
#    context .. parser context
#    dump ..... profile's dump string
sub appendProfile {
  my ($this, $context, $dump) = @_;
  push @{$this->{profiles}}, $dump;
}

# Make the task forcibly run
#
# Usage: setForceRun($context)
sub setForceRun {
  my ($this, $context) = @_;
  $this->{force_run} = 1;
}

return 1;
