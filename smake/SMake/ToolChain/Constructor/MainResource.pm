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

# Record of main resource for the generic constructor
package SMake::ToolChain::Constructor::MainResource;

use SMake::Model::Const;

# Create new record
#
# Usage: new($restype, $maintype, $mangler, $stage, $task, \%args)
#    restype .... type of the created resource
#    maintype ... type of the main resource (when it's searched from a dependency)
#    mangler .... mangler description for the main resource
#    stage ...... name of the stage which the resource is created in
#    task ....... type of the task which creates the resource
#    args ....... arguments of the task
sub new {
  my ($class, $restype, $maintype, $mangler, $stage, $task, $args) = @_;
  return bless({
    restype => $restype,
  	maintype => $maintype,
    mangler => $mangler,
    stage => $stage,
    task => $task,
    args => $args,
  }, $class);
}

# Create main resource
#
# Usage: createMainResource($context, $artifact)
sub createMainResource {
  my ($this, $context, $artifact) = @_;

  # -- create name of the main resource
  my $prefix = $context->getResourcePrefix();
  my $path = $prefix->joinPaths($artifact->getName());
  my $name = $context->getMangler()->mangleName($context, $this->{mangler}, $path);
  
  # -- create a task which creates the main resource
  my $task = $artifact->createTaskInStage(
      $context,
      $this->{stage},
      $name->asString(),
      $this->{task},
      $SMake::Model::Const::PRODUCT_LOCATION,
      $artifact->getPath()->joinPaths($name->getDirpath()),
      $this->{args});
  
  # -- create the resource
  my $resource = $artifact->createProductResource(
      $context, $this->{restype}, $name, $task);
  
  # -- append the main resource
  $artifact->appendMainResource($context, $this->{maintype}, $resource);
}

return 1;
