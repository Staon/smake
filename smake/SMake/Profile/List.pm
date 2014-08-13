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

# List of profiles
package SMake::Profile::List;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

# Create new profile list
#
# Usage: new($profile*)
sub new {
  my ($class, @profiles) = @_;
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{profiles} = [];
  $this->appendProfile(@profiles);
  return $this;
}

# Append a profile into the list
#
# Usage: appendProfile($profile*)
sub appendProfile {
  my ($this, @profiles) = @_;
  push @{$this->{profiles}}, @profiles;
}

# Create model objects of profile data
#
# Usage: constructProfiles($context, $task)
#    context ..... parser context
#    task ........ a task which the profiles are created for
sub constructProfiles {
  my ($this, $context, $task) = @_;

  foreach my $profile (@{$this->{profiles}}) {
    $profile->constructProfiles($context, $task);
  }
}

sub iterateItems {
  my ($this, $func) = @_;
  
  foreach my $item (@{$this->{profiles}}) {
    &$func($item);
  }
}

# Begining of construction of a project
#
# Usage: projectBegin($context, $subsystem, $project)
#    context ..... parser context
#    subsystem ... logging subsystem
#    project ..... the project
sub projectBegin {
  my ($this, $context, $subsystem, $project) = @_;
  $this->iterateItems(sub { $_[0]->projectBegin($context, $subsystem, $project); });
}

# Ending of construction of a project
#
# Usage: projectEnd($context, $subsystem, $project)
#    context ..... parser context
#    subsystem ... logging subsystem
#    project ..... the project
sub projectEnd {
  my ($this, $context, $subsystem, $project) = @_;
  $this->iterateItems(sub { $_[0]->projectEnd($context, $subsystem, $project); });
}

# Beginning of construction of an artifact
#
# Usage: artifactBegin($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub artifactBegin {
  my ($this, $context, $subsystem, $artifact) = @_;
  $this->iterateItems(sub { $_[0]->artifactBegin($context, $subsystem, $artifact); });
}

# Ending of construction of an artifact
#
# Usage: artifactEnd($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub artifactEnd {
  my ($this, $context, $subsystem, $artifact) = @_;
  $this->iterateItems(sub { $_[0]->artifactEnd($context, $subsystem, $artifact); });
}

# Modify a resolved resource
#
# Usage: modifyResource($context, $subsystem, $resource, $task)
#    context ..... parser context
#    subsystem ... logging subsystem
#    resource .... the resolved resource
#    task ........ the task
sub modifyResource {
  my ($this, $context, $subsystem, $resource, $task) = @_;
  $this->iterateItems(sub { $_[0]->modifyResource($context, $subsystem, $resource, $task); });
}

# Modify logical command
#
# Usage: modifyCommand($context, $command, $task)
#    context .... executor context
#    command .... the logical command
#    task ....... a task object which the command is attached to
# Returns: modified logical command
sub modifyCommand {
  my ($this, $context, $command, $task) = @_;

  $this->iterateItems(sub { $command = $_[0]->modifyCommand($context, $command, $task); });
  return $command;
}

# Get profile variable
#
# Usage: getVariable($context, $name)
#    context .... parser/executor context
#    name ....... name of the variable
sub getVariable {
  my ($this, $context, $name) = @_;
  
  my $value = undef;
  $this->iterateItems(sub {
    my $val = $_[0]->getVariable($context, $name);
    if(defined($val)) {
      $value = $val;
    }
  });
  return $value;
}

return 1;
