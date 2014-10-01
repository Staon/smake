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

# Standard cleaning stage of the artifact
package SMake::Platform::Generic::FinishClean;

use SMake::ToolChain::Constructor::FinishRecord;

@ISA = qw(SMake::ToolChain::Constructor::FinishRecord);

use SMake::Platform::Generic::Const;

# Create new record
sub new {
  my ($class) = @_;
  my $this = bless(SMake::ToolChain::Constructor::FinishRecord->new(), $class);
  return $this;
}

sub finish {
  my ($this, $context, $artifact, $constructor) = @_;

  # -- add cleaning stage and task
  my $task = $artifact->createTaskInStage(
      $context,
      $SMake::Platform::Generic::Const::CLEAN_STAGE,
      $SMake::Platform::Generic::Const::CLEAN_STAGE,
      $SMake::Platform::Generic::Const::CLEAN_TASK,
      undef,
      undef,
      undef);
}

return 1;
