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

# Updateable timestamp object
package SMake::Update::Timestamp;

# Create new timestamp object
#
# Usage: new($context, $task, $resource)
#    context ..... parser context
#    task ........ parent task object
#    resource .... a resource which the timestamp is for
sub new {
  my ($class, $context, $task, $resource) = @_;
  my $this = bless({}, $class);

  my $ts = $task->getObject()->getSourceTimestamp(
      $resource->getType(), $resource->getName());
  if(!defined($ts)) {
    $ts = $task->getObject()->createSourceTimestamp($resource->getObject());
  }
  $this->{task} = $task;
  $this->{resource} = $resource;
  $this->{timestamp} = $ts;
  
  return $this;
}

# Update the timestamp object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;
  
  $this->{task} = undef;
  $this->{resource} = undef;
  $this->{timestamp} = undef;
}

# Get string key
sub getKeyTuple {
  my ($this) = @_;
  return $this->{resource}->getKeyTuple();
}

# Get string key
sub getKey {
  my ($this) = @_;
  return $this->{resource}->getKey();
}

# Get resource type
sub getType {
  my ($this) = @_;
  return $this->{resource}->getType();
}

# Get resource name
sub getName {
  my ($this) = @_;
  return $this->{resource}->getName();
}

# Get timestamp mark of the resource
sub getMark {
  my ($this) = @_;
  return $this->{timestamp}->getMark();
}

# Get the resource
sub getResource {
  my ($this) = @_;
  return $this->{resource};
}

return 1;
