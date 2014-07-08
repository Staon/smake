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

# Generic interface of source scanner. The scanners parse source
# files and construct external resources which are needed to compile
# the source (typically C/C++ headers).
package SMake::ToolChain::Scanner::Scanner;

use SMake::Utils::Abstract;

# Create new source scanner
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Scan a source file
#
# Usage: scanSource($context, $queue, $artifact, $resource, $task)
#    context ........ parser context
#    queue .......... queue of resources during construction of an artifact
#    artifact ....... resource's artifact
#    resource ....... the scanned resource
#    task ........... a task which the resource is a source for
# Returns: true if the scanner processed the resource
sub scanSource {
  SMake::Utils::Abstract::dieAbstract();
}

# A helper method - install an external resource
#
# Usage: installExternalResource($context, $artifact, $resource, $task, $path)
#    context ...... parser context
#    artifact ..... artifact of the scanned resource
#    resource ..... the scanned resource
#    task ......... a task which the scanned resource is a source for
#    path ......... path of the external resource
sub installExternalResource {
  my ($this, $context, $artifact, $resource, $task, $path) = @_;

  # -- create the installation stage
  my $stagename = "install:" . $path->asString();
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
        $context, $path, $SMake::Model::Const::EXTERNAL_RESOURCE, $insttask);
  }
  else {
    $extres = $artifact->getResource(
        $SMake::Model::Const::EXTERNAL_RESOURCE, $path);
    if(!defined($extres)) {
      die "there is something wrong: resource '" . $path->asString() . "' is missing!";
    }
  }
  
  # -- append stage dependency
  $task->appendSource($context, $extres);
}

return 1;
