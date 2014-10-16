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

# Compilation of some resource
package SMake::ToolChain::Resolver::Compile;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Model::Const;
use SMake::ToolChain::Constructor::Constructor;

# Create new resolver
#
# Usage: new($type, $file, $stage, $tasktype, [$tgtype, $mangler]*)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    stage ..... name of the stage, which the compilation task is run in
#    tasktype .. type of the compilation task
#    tgtype .... type of the target resource
#    mangler ... mangler description of name of the target resource
sub new {
  my ($class, $type, $file, $stage, $tasktype, @records) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{stage} = $stage;
  $this->{tasktype} = $tasktype;
  $this->{records} = [@records];
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  # -- create the task and resource
  my $artifact = $context->getArtifact();
  my $task;

  # -- create target resources
  foreach my $record (@{$this->{records}}) {
    my ($tgtype, $mangler) = @$record;

    # -- create name of the new resource
    my $tgpath = $context->getMangler()->mangleName(
        $context, $mangler, $resource->getName());

    # -- create the task and resource
    if(!defined($task)) {
      $task = $artifact->createTaskInStage(
          $context,
          $this->{stage},
          $tgpath->asString(),
          $this->{tasktype},
          $SMake::Model::Const::PRODUCT_LOCATION,
          $artifact->getPath(),
          undef);
      $task->appendSource($context, $resource);
      
      # -- execute source scanner
      $context->scanSource($queue, $artifact, $resource, $task);
    }
    
    # -- create the resource
    my $tgres = $artifact->createProductResource(
        $context, $tgtype, $tgpath, $task);
    $queue->pushResource($tgres);

    # -- notify the profiles
    $context->getProfiles()->modifyResource(
        $context,
        $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
        $resource,
        $task);
  }
}

return 1;
