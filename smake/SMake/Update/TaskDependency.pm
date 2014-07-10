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

# Updateable task dependency object
package SMake::Update::TaskDependency;

# Create new dependency object
#
# Usage: new($context, $task, $dependency, $instmodule)
#    context ...... parser context
#    task ......... parent artifact object
#    dependency ... dependency object
#    instmodule ... installation module
sub new {
  my ($class, $context, $task, $dependency, $instmodule) = @_;
  my $this = bless({}, $class);

  my $taskdep = $task->getObject()->getDependency($dependency->getKeyTuple());
  if(defined($taskdep)) {
    $taskdep->update($instmodule);
  }
  else {
    $taskdep = $task->getObject()->createDependency(
        $dependency->getObject(), $instmodule);
  }
  $this->{task} = $task;
  $this->{taskdep} = $taskdep;
  $this->{instmodule} = $instmodule;
  
  return $this;
}

# Update data of the object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;
  
  $this->{task} = undef;
  $this->{taskdep} = undef;
  $this->{instmodule} = undef;
}

# Get the model object
sub getObject {
  my ($this) = @_;
  return $this->{taskdep};
}

# Get a string which can be used as a hash key
sub getKeyTuple {
  my ($this) = @_;
  return $this->{taskdep}->getKeyTuple();
}

# Get a string which can be used as a hash key
sub getKey {
  my ($this) = @_;
  return $this->{taskdep}->getKey();
}

# Get dependency task
sub getTask {
  my ($this) = @_;
  return $this->{task};
}

# Get type of the dependency
sub getDependencyType {
  my ($this) = @_;
  return $this->{taskdep}->getDependencyType();
}

# Get a name of the project
sub getDependencyProject {
  my ($this) = @_;
  return $this->{taskdep}->getDependencyProject();
}

# Get name of the artifact
sub getDependencyArtifact {
  my ($this) = @_;
  return $this->{taskdep}->getDependencyArtifact();
}

# Get type of the references main resource
#
# Usage: name of the type or undef if the default main resource should be used
sub getDependencyMainResource {
  my ($this) = @_;
  return $this->{taskdep}->getDependencyMainResource();
}

return 1;
