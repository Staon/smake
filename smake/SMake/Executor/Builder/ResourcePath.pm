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

# Create a resource node with physical path to a resource
package SMake::Executor::Builder::ResourcePath;

use SMake::Executor::Builder::Record;

@ISA = qw(SMake::Executor::Builder::Record);

use SMake::Data::Path;
use SMake::Executor::Command::Group;
use SMake::Executor::Command::Set;
use SMake::Executor::Command::Value;
use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new record
#
# Usage: new($group, $unique, $project, $artifact, $resname, $dir)
#    group ...... name of the command group
#    unique ..... if it's true the group is a set
#    project .... name of the resolved project
#    artifact ... name of the resolved artifact
#    resname .... name of the resolved resource (a Path object)
#    dir ........ if it's true, name of resource's directory is filled in
sub new {
  my ($class, $group, $unique, $project, $artifact, $resname, $dir) = @_;
  my $this = bless(SMake::Executor::Builder::Record->new(), $class);
  
  $this->{group} = $group;
  $this->{unique} = $unique;
  $this->{project} = $project;
  $this->{artifact} = $artifact;
  if(ref($resname) eq "SMake::Data::Path") {
    $this->{resname} = $resname;
  }
  else {
    $this->{resname} = SMake::Data::Path->new($resname);
  }
  $this->{dirflag} = $dir;
    
  return $this;  
}

sub compose {
  my ($this, $context, $task, $command) = @_;
  my $repository = $context->getRepository();

  # -- search for the project
  my ($prjobj, $prjlocal) = $repository->getProject($this->{project});
  if(!defined($prjobj)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "unknown project '%s'!",
        $this->{project});
  }

  # -- search for the artifact
  my $artobj = $prjobj->getArtifact($this->{artifact});
  if(!defined($artobj)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "the project '%s' doesn't contain any artifact '%s'!",
        $this->{project},
        $this->{artifact});
  }

  # -- search for the resource
  my $resobj = $artobj->searchResource('.*', $this->{resname}, '.*');
  if(!defined($resobj)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "the resource '%s' cannot be found in the artifact '%s' of the project '%s'!",
        $this->{resname}->asString(),
        $this->{artifact},
        $this->{project});
  }
  
  # -- construct the group
  my $group = $command->getChild($this->{group});
  if(!defined($group)) {
    if($this->{unique}) {
      $group = SMake::Executor::Command::Set->new($this->{group});
    }
    else {
      $group = SMake::Executor::Command::Group->new($this->{group});
    }
    $command->putChild($group);
  }

  # -- create the command node  
  my $node;
  if($this->{dirflag}) {
    $node = $this->createResourceDirNode($context, $resobj);
  }
  else {
    $node = $this->createResourceNode($context, $resobj);
  }
  $group->addChild($node);
}

return 1;
