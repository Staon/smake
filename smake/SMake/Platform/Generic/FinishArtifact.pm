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

# Standard finishing of constructed artifacts
package SMake::Platform::Generic::FinishArtifact;

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

  # -- create the service artifact, stage and task
  my $project = $artifact->getProject();
  my $service = $project->getArtifact(
      $SMake::Platform::Generic::Const::SERVICE_ARTIFACT);
  if(!defined($service)) {
    $service = $project->createArtifact(
        $context,
        $project->getPath(),
        $SMake::Platform::Generic::Const::SERVICE_ARTIFACT,
        $SMake::Platform::Generic::Const::SERVICE_ARTIFACT,
        undef);
    $service->createTaskInStage(
        $context,
        $SMake::Platform::Generic::Const::SERVICE_STAGE,
        $SMake::Platform::Generic::Const::SERVICE_STAGE,
        $SMake::Platform::Generic::Const::SERVICE_TASK,
        undef,
        undef,
        undef);
  }
  
  # -- make all stages dependent
  my $servicedep = $artifact->createStageDependency(
      $context,
      $SMake::Platform::Generic::Const::SERVICE_DEPENDENCY,
      $project->getName(),
      $SMake::Platform::Generic::Const::SERVICE_ARTIFACT,
      $SMake::Platform::Generic::Const::SERVICE_STAGE);
  my $stages = $artifact->getStages();
  foreach my $stage (@$stages) {
    my $taskdep = $stage->createTask(
        $context,
        $SMake::Platform::Generic::Const::SERVICE_DEP_TASK,
        $SMake::Platform::Generic::Const::SERVICE_DEP_TASK,
        undef,
        undef,
        undef);
    $taskdep->appendDependency($context, $servicedep, undef);
  }
}

return 1;
