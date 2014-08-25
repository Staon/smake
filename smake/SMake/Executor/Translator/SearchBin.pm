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

# Search path of binary from another smake project
package SMake::Executor::Translator::SearchBin;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

use SMake::Executor::Executor;
use SMake::Executor::Instruction::Shell;
use SMake::Model::Dependency;
use SMake::Utils::PathUtils;
use SMake::Utils::Searching;

# Create new value translator
#
# Usage: new($project, $artifact, $mainres)
#    project .... project name
#    artifact ... name of the artifact
#    mainres .... name of the main resource. If it's null, the default resource is used.
sub new {
  my ($class, $project, $artifact, $mainres) = @_;
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{project} = $project;
  $this->{artifact} = $artifact;
  $this->{mainres} = $mainres;
  return $this;
}

sub translate {
  my ($this, $context, $task, $command, $wd) = @_;

  # -- get the resource object
  my ($project, $artifact, $stage, $resource) = SMake::Utils::Searching::resolveDependency(
      $context,
      $SMake::Executor::Executor::SUBSYSTEM,
      @{SMake::Model::Dependency::createKeyTuple(
          $SMake::Model::Dependency::RESOURCE_KIND,
          "foo",
          $this->{project},
          $this->{artifact},
          $this->{mainres},
      )});
  if(!defined($resource)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "binary tool '%s/%s%s' cannot be resolved!",
        $this->{project},
        $this->{artifact},
        (defined($this->{mainres})?("/" . $this->{mainres}):""));
  }
  
  # -- create physical path of the resource
  my $pathstr = SMake::Utils::PathUtils::getSystemArgument(
      $context, $resource->getPhysicalPath(), $wd, undef);
  
  return [SMake::Executor::Instruction::Shell->new($pathstr)];
}

return 1;
