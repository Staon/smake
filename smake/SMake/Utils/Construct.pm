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

# Helper functions for project construction
package SMake::Utils::Construct;

use SMake::Data::Path;
use SMake::Model::Const;

# A helper method - install an external resource
#
# Usage: installExternalResource($context, $artifact, $resource, $task, $path)
#    context ...... parser context
#    artifact ..... artifact of the scanned resource
#    resource ..... the scanned resource
#    task ......... a task which the scanned resource is a source for
#    module ....... installation module
#    name ......... name of the external resource
sub installExternalResource {
  my ($context, $artifact, $resource, $task, $module, $name) = @_;

  # -- create the installation stage
  $name = SMake::Data::Path->new($name);
  my $stagename = "install:" . $name->asString();
  my $stage = $artifact->getStage($stagename);
  my $extres;
  if(!defined($stage)) {
    # -- create installation task
    my $insttask = $artifact->createTaskInStage(
        $context,
        $stagename,
        $stagename,
        $SMake::Model::Const::EXTERNAL_TASK,
        undef,
        undef,
        undef);
    # -- create the external resource
    $extres = $artifact->createResource(
        $context,
        $SMake::Model::Const::EXTERNAL_LOCATION,
        $module,
        $name,
        $insttask);
  }
  else {
    $extres = $artifact->getResource(
        $SMake::Model::Const::EXTERNAL_LOCATION, $module, $name);
    if(!defined($extres)) {
      die "there is something wrong: resource '" . $name->asString() . "' is missing!";
    }
  }
  
  # -- append stage dependency
  $task->appendSource($context, $extres);
}

return 1;