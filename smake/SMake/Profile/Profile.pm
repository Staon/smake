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

# Generic profile interface
package SMake::Profile::Profile;

use Data::Dumper;

# Create new profile object
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Dump a content of the profile to be restored by the function ressurect()
sub dumpContent {
  my ($this) = @_;
  
  if(!defined($this->{cached_profile_data})) {
    my $dumper = Data::Dumper->new([$this], [qw(profile)]);
    $dumper->Indent(0);  # -- one line
    $dumper->Purity(1);
    $dumper->Sortkeys(1); # -- sorting of hash keys
    $this->{cached_profile_data} = $dumper->Dump();
  }
  return $this->{cached_profile_data};
}

# (static) ressurect a profile object from a dump string
#
# Usage: ressurect($dump)
#    dump ..... the dump string
# Returns: the profile object
sub ressurect {
  my ($dump) = @_;
  
  local $profile;
  my $info = eval $dump;
  if(!defined($info) && (defined($@) && $@ ne "")) {
    die "it's not possible to create profile object!";
  }
  return $profile;
}

# Create model objects of profile data
#
# Usage: constructProfiles($context, $task)
#    context ..... parser context
#    task ........ a task which the profiles are created for
sub constructProfiles {
  my ($this, $context, $task) = @_;
  
  if($this->isExecutionProfile($context)) {
    my $dumpstring = $this->dumpContent();
    $task->appendProfile($context, $dumpstring);
  }
}

# It returns true, if the profile modifies behavior of the executor
#
# Usage: isExecutionProfile($context)
# Returns: true/false
sub isExecutionProfile {
  my ($this, $context) = @_;
  return 0;
}

# Begining of construction of a project
#
# Usage: projectBegin($context, $subsystem, $project)
#    context ..... parser context
#    subsystem ... logging subsystem
#    project ..... the project
sub projectBegin {
  # -- nothing to do as the default
}

# Ending of construction of a project
#
# Usage: projectEnd($context, $subsystem, $project)
#    context ..... parser context
#    subsystem ... logging subsystem
#    project ..... the project
sub projectEnd {
  # -- nothing to do as the default
}

# Beginning of construction of an artifact
#
# Usage: artifactBegin($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub artifactBegin {
  # -- nothing to do as the default
}

# Ending of construction of an artifact
#
# Usage: artifactEnd($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub artifactEnd {
  # -- nothing to do as the default
}

# Modify a resolved resource
#
# This event is raised by several resolvers after they create new task
# and new product resource. The task and the source resource can be modified
# here.
#
# Usage: modifyResource($context, $subsystem, $resource, $task)
#    context ..... parser context
#    subsystem ... logging subsystem
#    resource .... the resolved resource
#    task ........ the task
sub modifyResource {
  # -- nothing to do as the default
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

  # -- nothing to do as the default
  return $command;
}

# Get profile variable
#
# Usage: getVariable($context, $name)
#    context .... executor/parser context
#    name ....... name of the variable
# Returns: value of the variable or undef
sub getVariable {
  return undef;
}

return 1;
