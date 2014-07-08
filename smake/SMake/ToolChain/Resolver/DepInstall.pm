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

# Dependency installation resolver
package SMake::ToolChain::Resolver::DepInstall;

use SMake::ToolChain::Resolver::Dependency;

@ISA = qw(SMake::ToolChain::Resolver::Dependency);

use SMake::Model::Const;

# Create new dependency installation resolver
#
# Usage: new($mask, $stage, $mainres|[$mainres*], $instmodule)
#    mask ........ mask of the dependency type
#    stage ....... name of the installation stage
#    mainres ..... list of main resources which are dependent on the installation
#        stage.
#    instmodule .. installation module
sub new {
  my ($class, $mask, $stage, $mainres, $instmodule) = @_;

  my $this = bless(SMake::ToolChain::Resolver::Dependency->new($mask), $class);
  $this->{stage} = $stage;
  if(ref($mainres) eq "ARRAY") {
    $this->{mainres} = $mainres;
  }
  else {
    $this->{mainres} = [$mainres];
  }
  $this->{instmodule} = $instmodule;
  return $this;
}

sub doJob {
  my ($this, $context, $dependency) = @_;
  
  # -- create the installation stage, if it's needed
  my $artifact = $context->getArtifact();
  my $stage = $artifact->getStage($this->{stage});
  my $task;
  if(!defined($stage)) {
    $task = $artifact->createTaskInStage(
        $context,
        $this->{stage},
        $this->{stage},
        $SMake::Model::Const::EXTERNAL_TASK,
        undef,
        undef,
        undef);
  }
  else {
    $task = $stage->getTask($this->{stage});
  }
  
  # -- insert dependency into the installation task
  $task->appendDependency($context, $dependency, $this->{instmodule});

  # -- get installation dependency
  my $instdep = $artifact->getDependency(
      $SMake::Model::Dependency::STAGE_KIND,
      $SMake::Model::Const::INSTALL_DEPENDENCY,
      $artifact->getProject()->getName(),
      $artifact->getName(),
      $this->{stage});
  if(!defined($instdep)) {
    $instdep = $artifact->createStageDependency(
        $context,
        $SMake::Model::Const::INSTALL_DEPENDENCY,
        $artifact->getProject()->getName(),
        $artifact->getName(),
        $this->{stage});
  }
    
  # -- create stage dependency for main resources
  foreach my $mainr (@{$this->{mainres}}) {
    my $mainres = $artifact->getMainResource($mainr);
    if(!defined($mainres)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
          "installation stage cannot be attached to main resource '%s'",
          $mainr);
    }
    my $task = $mainres->getTask();
    $task->appendDependency($context, $instdep, undef);
  }
}

return 1;
