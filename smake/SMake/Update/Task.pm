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
    # -- todo
  }
  else {
    $task = $stage->getObject()->createTask($name, $type, $wd, $args);
  }
  $this->{targets} = {};
  $this->{stage} = $stage;
  $this->{task} = $task;
  
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{stage} = undef;
  $this->{task} = undef;
}

# Get model task object
sub getObject {
  my ($this) = @_;
  return $this->{task};
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
