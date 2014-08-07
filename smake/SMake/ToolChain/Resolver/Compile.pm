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

# Create new resolver
#
# Usage: new($type, $file, $tgtype, $mangler, $stage, $tasktype)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    tgtype .... type of the target resource
#    mangler ... mangler description of name of the target resource
#    stage ..... name of the stage, which the compilation task is run in
#    tasktype .. type of the compilation task
sub new {
  my ($class, $type, $file, $tgtype, $mangler, $stage, $tasktype) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{tgtype} = $tgtype;
  $this->{mangler} = $mangler;
  $this->{stage} = $stage;
  $this->{tasktype} = $tasktype;
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  # -- create name of the new resource
  my $tgpath = $context->getMangler()->mangleName(
      $context, $this->{mangler}, $resource->getName());

  # -- create the task and the resource
  my $artifact = $context->getArtifact();
  my $task = $artifact->createTaskInStage(
      $context,
      $this->{stage},
      $tgpath->asString(),
      $this->{tasktype},
      $SMake::Model::Const::PRODUCT_LOCATION,
      $artifact->getPath(),
      undef);
  $task->appendSource($context, $resource);
  my $tgres = $artifact->createProductResource(
      $context, $this->{tgtype}, $tgpath, $task);
  $queue->pushResource($tgres);
  
  # -- execute source scanner
  $context->scanSource($queue, $artifact, $resource, $task);
}

return 1;
