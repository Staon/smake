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
package SMake::Constructor::MainResource;

use SMake::Model::Const;

# Create new record
#
# Usage: new($maintype, $mangler, $stage, $task, \%args)
#    maintype ... type of the main resource
#    mangler .... mangler description for the main resource
#    stage ...... name of the stage which the resource is created in
#    task ....... type of the task which creates the resource
#    args ....... arguments of the task
sub new {
  my ($class, $maintype, $mangler, $stage, $task, $args) = @_;
  return bless({
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
  
  # -- create a task which creates the main resource
  my $task = $artifact->createTaskInStage(
      $this->{stage}, $this->{task}, $artifact->getPath(), $this->{args});
  
  # -- create the resource
  my $prefix = $context->getResourcePrefix();
  my $path = $prefix->joinPaths($artifact->getName());
  my $name = $context->getMangler()->mangleName($context, $this->{mangler}, $path);
  my $resource = $artifact->createResource(
      $name, $SMake::Model::Const::PRODUCT_RESOURCE, $task);
  
  # -- append the main resource
  $artifact->appendMainResource($this->{maintype}, $resource);
}

return 1;
