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

# Install an external resource into the installation area
package SMake::Executor::Instruction::Install;

use SMake::Executor::Instruction::Instruction;

@ISA = qw(SMake::Executor::Instruction::Instruction);

use SMake::Executor::Executor;

# Create new instruction
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Executor::Instruction::Instruction->new(), $class);
  return $this;
}

sub execute {
  my ($this, $context, $taskaddress, $wdir) = @_;

  # -- get model objects
  my ($project, $artifact, $stage, $task) = $taskaddress->getObjects(
      $context, $SMake::Executor::Executor::SUBSYSTEM);

  # -- install the resources
  my $resources = $task->getTargets();
  foreach my $resource (@$resources) {
    $project->installResource(
        $context,
        $SMake::Executor::Executor::SUBSYSTEM,
        $resource);
  }
  
  # -- install resource dependencies
  my $deps = $task->getDependencies();
  foreach my $dep (@$deps) {
    $project->installDependency(
        $context,
        $SMake::Executor::Executor::SUBSYSTEM,
        $dep);
  }
  
  return $SMake::Executor::Instruction::Instruction::NEXT;
}

return 1;
