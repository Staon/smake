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

# Clean all product resources in active artifact
package SMake::Executor::Instruction::CreateDirectory;

use SMake::Executor::Instruction::Instruction;

@ISA = qw(SMake::Executor::Instruction::Instruction);

use SMake::Executor::Executor;
use SMake::Model::Const;
use SMake::Utils::Dirutils;

# Create new check mark instruction
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Executor::Instruction::Instruction->new(), $class);
}

sub execute {
  my ($this, $context, $taskaddress, $wdir) = @_;

  # -- get model objects
  my ($project, $artifact, $stage, $task) = $taskaddress->getObjects(
      $context, $SMake::Executor::Executor::SUBSYSTEM);
  
  # -- get all product resources
  my $list = $task->getTargets();
  foreach my $resource (@$list) {
    my $dirname = $resource->getPhysicalPathString();
    if(! -d $dirname) {
      my $msg = SMake::Utils::Dirutils::makeDirectory($dirname);
      if($msg) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $SMake::Executor::Executor::SUBSYSTEM,
            "cannot create product directory '%s': %s!",
            $dirname,
            $msg);
      }
    }
  }

  return $SMake::Executor::Instruction::Instruction::NEXT;
}

return 1;
