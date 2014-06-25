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

# Updateable resource object
package SMake::Update::Resource;

# Create new resource object
#
# Usage: new($context, $artifact, $name, $type, $task)
#    context ..... parser context
#    artifact .... parent artifact object
#    name ........ name of the resource (relative path)
#    type ........ type of the resource
#    task ........ a task object which creates the resource
sub new {
  my ($class, $context, $artifact, $name, $type, $task) = @_;
  my $this = bless({}, $class);
  
  my $resource = $artifact->getObject()->getResource($name);
  if(defined($resource)) {
    $resource->update($type, $task->getObject());
  }
  else {
    $resource = $artifact->getObject()->createResource(
        $name, $type, $task->getObject());
  }
  $this->{artifact} = $artifact;
  $this->{resource} = $resource;
  
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{artifact} = undef;
  $this->{resource} = undef;
}

# Get model resource object
sub getObject {
  my ($this) = @_;
  return $this->{resource};
}

# Get resource name (a path object)
sub getName {
  my ($this) = @_;
  return $this->{resource}->getName();
}

# Get a string which is usable as a hash key
sub getKey {
  my ($this) = @_;
  return $this->{resource}->getKey();
}

return 1;
