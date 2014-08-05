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

# Generic link resolver. The link is meant to be last phase when
# an artifact main resource is constructed from already created
# resources.
package SMake::ToolChain::Resolver::Link;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Utils::Utils;

# Create new resolver
#
# Usage: new($type, $file, $maintype, [$mangler, $tasktype, $newmain])
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    maintype .. type of the main resource
#    mangler ... (optional) mangler of the name of the main resource
#    tasktype .. type of the task which creates the mangled resource
#    newmain ... main resource type of the newly created resource
sub new {
  my ($class, $type, $file, $maintype, $mangler, $tasktype, $newmain) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{maintype} = $maintype;
  $this->{mangler} = $mangler;
  $this->{tasktype} = $tasktype;
  $this->{newmain} = $newmain;
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  # -- get the main resource
  my $artifact = $context->getArtifact();
  my $main_resource = $artifact->getMainResource($this->{maintype});
  if(!defined($main_resource)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        "resolver",
        "artifact '%s' doesn't define a main resource of type '%s'",
        $artifact->getName(),
        $this->{maintype});
  }
  
  # -- create new resource if it should be done
  if(defined($this->{mangler})) {
    my $path = $context->getMangler()->mangleName(
        $context, $this->{mangler}, $main_resource->getName());
    my $resource = $artifact->getResource(
        $SMake::Model::Const::PRODUCT_RESOURCE, $path);
    if(!defined($resource)) {
      my $task = $artifact->createTaskInStage(
          $context,
          $main_resource->getStage()->getName(),
          $path->asString(),
          $this->{tasktype},
          $main_resource->getTask()->getWDType(),
          $main_resource->getTask()->getWDPath(),
          undef);
      $resource = $artifact->createProductResource(
          $context, $path, $SMake::Model::Const::PRODUCT_RESOURCE, $task);
      $artifact->appendMainResource($context, $this->{newmain}, $resource);
      $queue->pushResource($resource);
    }
    $main_resource = $resource;
  }
  
  # -- append resolved resource to list of source resources of the task
  #    which creates the main resource
  my $task = $main_resource->getTask();
  $task->appendSource($context, $resource);
}

return 1;
