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

# Generic command resolver. The resolver allows to specify commands
# for stages. It's designated to integrate smake with another build
# systems (make, ant, maven).
package SMake::ToolChain::Resolver::Command;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Data::Path;
use SMake::Executor::Translator::Compositor;
use SMake::Model::Const;
use SMake::Parser::Parser;
use SMake::ToolChain::Resolver::Empty;
use SMake::Utils::Masks;

# Create new resolver
#
# Usage: new($type, $file, $tasktype, $spec)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    tasktype .. type of the command task
#    spec ...... a reference to a hash in format:
#                  {
#                    stages => {
#                      main => {
#                        mainname => resource,
#                      },
#                      stage => {
#                        targets => [ list of target resources ],
#                        sources => [ list of sources resources ],
#                        command => [ list of command translators ],
#                        deps => [type, [ list of dependency specification ]],
#                      },...
#                    }
#                  }
sub new {
  my ($class, $type, $file, $tasktype, $spec) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{tasktype} = $tasktype;
  $this->{spec} = $spec;
  
  return $this;
}

sub createTaskName {
  my ($stagename) = @_;
  return "command:" . $stagename;
}

sub getDirectResource {
  my ($artifact, $resname) = @_;
  my $resource = $artifact->getResource(
      $SMake::Model::Const::PRODUCT_LOCATION,
      $SMake::Model::Const::SOURCE_RESOURCE,
      SMake::Data::Path->new($resname));
  if(!defined($resource)) {
    die "direct resource '$resname' doesn't exist!";
  }
  return $resource;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  my $artifact = $context->getArtifact();

  # -- create resources and theirs creational tasks
  foreach my $stagename (keys %{$this->{spec}->{stages}}) {
    my $stage = $this->{spec}->{stages}->{$stagename};
    
    # -- create the task
    my $task = $artifact->createTaskInStage(
        $context,
        $stagename,
        createTaskName($stagename),
        $this->{tasktype},
        $SMake::Model::Const::SOURCE_LOCATION,
        $artifact->getPath(),
        { translator => 
              SMake::Executor::Translator::Compositor->new(1, @{$stage->{command}}) });

    # -- create the resources
    my $targets = $stage->{targets};
    if(defined($targets)) {
      foreach my $resname (@$targets) {
        my $respath = $resname;
        $respath =~ s/^[!]//;
        
        # -- create the resource
        my $tgres = $artifact->createProductResource(
            $context,
            $SMake::Model::Const::SOURCE_RESOURCE,
            SMake::Data::Path->new($respath),
            $task);
        
        # -- resolve the resource
        if($resname !~ /^[!]/) {
          $queue->pushResource($tgres);
        }
      }
    }
  }
  
  # -- stage and task dependencies
  foreach my $stagename (keys %{$this->{spec}->{stages}}) {
    my $stage = $this->{spec}->{stages}->{$stagename};
    my $task = $artifact->getStage($stagename)->getTask(createTaskName($stagename));

    # -- resource dependencies
    my $sources = $stage->{sources};
    if(defined($sources)) {
      foreach my $resname (@$sources) {
        $task->appendSource($context, getDirectResource($artifact, $resname));
      }
    }
    
    # -- dependency specification
    my $deps = $stage->{deps};
    if(defined($deps)) {
      foreach my $dep (@$deps) {
        my ($deptype, $instmodule, $depspec) = @$dep;
        my $deplist = $artifact->appendDependencySpecs(
            $context, $SMake::Parser::Parser::SUBSYSTEM, $deptype, [$depspec]);
        $task->appendDependency($context, $deplist->[0], $instmodule);
      }
    }
  }  
  
  # -- register main resources
  foreach my $mainname (keys %{$this->{spec}->{main}}) {
    my $resname = $this->{spec}->{main}->{$mainname};
    $artifact->appendMainResource(
        $context, $mainname, getDirectResource($artifact, $resname));
  }
}

return 1;
