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

# Simply change type and name and location of a resource
package SMake::ToolChain::Resolver::ResourceTrans;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Model::Const;

# Create new resolver
#
# Usage: new($type, $file, $tgtype, $mangler, $location)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    tgtype .... new target resource type (can be undef)
#    mangler ... mangler description of name of the target resource (can be undef)
#    location .. target resource location (can be undef)
sub new {
  my ($class, $type, $file, $tgtype, $mangler, $location) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{tgtype} = $tgtype;
  $this->{mangler} = $mangler;
  $this->{tglocation} = $location;
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  # -- prepare new resource attributes
  my $tgtype = (defined($this->{tgtype}))?$this->{tgtype}:$resource->getType();
  my $tgname;
  if(defined($this->{mangler})) {
    $tgname = $context->getMangler()->mangleName(
        $context, $this->{mangler}, $resource->getName());
  }
  else {
    $tgname = $resource->getName();
  }
  my $tglocation = (defined($this->{tglocation}))?$this->{tglocation}:$resource->getLocation();
  
  # -- create the translation task and the resource
  my $artifact = $context->getArtifact();
  my $task = $artifact->createTaskInStage(
      $context,
      $resource->getStage()->getName(),
      "translate:" . $tgname->asString(),
      $SMake::Model::Const::RES_TRANSLATION_TASK,
      $resource->getTask()->getWDType(),
      $resource->getTask()->getWDPath(),
      $resource->getTask()->getArguments());
  $task->appendSource($context, $resource);
  my $tgres = $artifact->createResource(
      $context, $tglocation, $tgtype, $tgname, $task);
  $queue->pushResource($tgres);
}

return 1;
