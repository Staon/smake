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

# Publishing of a resource
package SMake::ToolChain::Resolver::Publish;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Model::Const;

# Create new publishing resolver
#
# Usage: new($type, $file, restype, path)
#    type ........ mask of type of the resources
#    file ........ mask of path of the resources
#    instmodule .. installation module
#    path ........ profile variable which contains installation path 
#                  (relative path based on the installation area)
sub new {
  my ($class, $type, $file, $instmodule, $path) = @_;
  
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{instmodule} = $instmodule;
  $this->{path} = $path;
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  my $artifact = $context->getArtifact();
  my $profvar = $context->getProfiles()->getVariable($context, $this->{path});
  if(defined($profvar)) {
    # -- construct name of the public resource
    my $path = SMake::Data::Path->new($profvar, $resource->getName()->getBasepath());
  
    # -- create the public resource and its task
    my $task = $artifact->createTaskInStage(
        $context,
        $resource->getStage()->getName(),
        "publish:" . $path->asString(),
        $SMake::Model::Const::PUBLISH_TASK,
        undef,
        undef,
        undef);
    my $instres = $artifact->createResource(
        $context, $SMake::Model::Const::PUBLIC_LOCATION, $this->{instmodule}, $path, $task);
    $instres->publishResource();
    $task->appendSource($context, $resource);
  }

  # -- execute source scanner
  $context->scanSource($queue, $artifact, $resource, $resource->getTask());
  
  return 1;
}

return 1;
