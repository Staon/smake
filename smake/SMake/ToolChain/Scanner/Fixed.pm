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

# Fixed resource scanner
package SMake::ToolChain::Scanner::Fixed;

use SMake::ToolChain::Scanner::Scanner;

@ISA = qw(SMake::ToolChain::Scanner::Scanner);

use SMake::Model::Const;
use SMake::ToolChain::Constructor::Constructor;
use SMake::Utils::Construct;
use SMake::Utils::Utils;

# Create new header scanner
#
# Usage: new($tasktype, $restype, $resname, \@[$instmodule, $mangler])
#    tasktype .... a regular expression which describes type of the task
#    restype ..... a regular expression which describes type of the resource
#    resname ..... a regular expression which describes name of the resource
#    copyext ..... if it's true, external resources are copied from resource's sources into the task
#    instmodule .. installation module name
#    mangler ..... mangler description of the scanned resource
sub new {
  my ($class, $tasktype, $restype, $resname, $copyext, $records) = @_;
  my $this = bless(SMake::ToolChain::Scanner::Scanner->new(), $class);
  $this->{tasktype} = $tasktype;
  $this->{restype} = $restype;
  $this->{resname} = $resname;
  $this->{copyext} = $copyext;
  $this->{records} = $records;
  return $this;
}

sub scanSource {
  my ($this, $context, $queue, $artifact, $resource, $task) = @_;
    
  # -- check task and resource masks
  if(($resource->getType() =~ /$this->{restype}/)
      && ($resource->getName()->asString() =~ /$this->{resname}/)
      && ($task->getType() =~ /$this->{tasktype}/)) {
    
    # -- append fixed resources
    foreach my $record (@{$this->{records}}) {
      # -- mangle the resource name
      my $path = $context->getMangler()->mangleName(
          $context, $record->[1], $resource->getName());
      
      # -- install the new resource
      SMake::Utils::Construct::installExternalResource(
          $context,
          $artifact,
          $resource,
          $task,
          $record->[0],
          $path);
    }
    
    # -- copy external resources from the source task
    my $sources = $resource->getTask()->getSources();
    foreach my $source (@$sources) {
      if($source->getLocation() eq $SMake::Model::Const::EXTERNAL_LOCATION) {
        SMake::Utils::Construct::installExternalResource(
            $context,
            $artifact,
            $resource,
            $task,
            $source->getType(),
            $source->getName());
      }
    }
    
    return 1;
  }
  else {
    return 0;
  }
}

return 1;
