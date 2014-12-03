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

# Generic pre-implementation of scanners
package SMake::ToolChain::Scanner::OrdinaryScanner;

use SMake::ToolChain::Scanner::Scanner;

@ISA = qw(SMake::ToolChain::Scanner::Scanner);

use SMake::Utils::Abstract;

# Create new header scanner
#
# Usage: new($tasktype, $restype, $resname)
#    tasktype .... a regular expression which describes type of the task
#    restype ..... a regular expression which describes type of the resource
#    resname ..... a regular expression which describes name of the resource
sub new {
  my ($class, $tasktype, $restype, $resname) = @_;
  my $this = bless(SMake::ToolChain::Scanner::Scanner->new(), $class);
  $this->{tasktype} = $tasktype;
  $this->{restype} = $restype;
  $this->{resname} = $resname;
  return $this;
}

sub scanSource {
  my ($this, $context, $queue, $artifact, $resource, $task) = @_;

  # -- check task and resource masks
  if(($resource->getType() =~ /$this->{restype}/)
      && ($resource->getName()->asString() =~ /$this->{resname}/)
      && ($task->getType() =~ /$this->{tasktype}/)) {
    return $this->doJob($context, $queue, $artifact, $resource, $task);
  }
  else {
    return 0;
  }
}

# Scan a source file. Resource types, names and task type are already checked)
#
# Usage: scanSource($context, $queue, $artifact, $resource, $task)
#    context ........ parser context
#    queue .......... queue of resources during construction of an artifact
#    artifact ....... resource's artifact
#    resource ....... the scanned resource
#    task ........... a task which the resource is a source for
# Returns: true if the scanner processed the resource
sub doJob {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
