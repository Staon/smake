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

# Generic modification of a resolved resource
package SMake::Profile::ResourceProfile;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

use SMake::Utils::Abstract;

# Create new command profile
#
# Usage: new($reslocation, $restype, $resname, $task)
#    reslocation ....... a regular expression to match the resource location
#    restype ........... a regular expression to match the resource type
#    resname ........... a regular expression to match the resource name
#    task .............. a regular expression to match the task
sub new {
  my ($class, $reslocation, $restype, $resname, $task) = @_;
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{reslocation} = $reslocation;
  $this->{restype} = $restype;
  $this->{resname} = $resname;
  $this->{task} = $task;
  return $this;
}

sub modifyResource {
  my ($this, $context, $subsystem, $resource, $task) = @_;
 
  if($resource->getLocation() =~ /^$this->{reslocation}$/
     && $resource->getType() =~ /^$this->{restype}$/
     && $resource->getName()->asString() =~ /^$this->{resname}$/
     && $task->getType() =~ /^$this->{task}/) {
    $this->doJob($context, $subsystem, $resource, $task);
  }
}

# Modify a resolved resource
#
# Usage: doJob($context, $subsystem, $resource)
#    context .... executor context
#    subsystem .. logging subsystem
#    resource ... the resolved resource
#    task ....... the task
sub doJob {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
