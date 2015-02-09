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
#    spec ...... a reference to a hash in format:
#                  {
#                    main => {
#                      mainname => resource,
#                    },
#                    stages => {
#                      stage => {
#                        task => {
#                          type => task type,
#                          targets => [ list of target resources ],
#                          sources => [ list of sources resources ],
#                          deps => [type, [ list of dependency specification ]],
#                          args => { command arguments }
#                        },...
#                      },...
#                    }
#                  }
sub new {
  my ($class, $type, $file, $spec) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{spec} = $spec;
  
  return $this;
}

sub getDirectResource {
  my ($artifact, $resname) = @_;
  
  my $resource = $artifact->searchResource(
    '.*',
    SMake::Data::Path->new($resname),
    '.*');
  if(!defined($resource)) {
    die "direct resource '$resname' doesn't exist!";
  }
  return $resource;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  my $artifact = $context->getArtifact();

  # -- create target resources and theirs creational tasks
  foreach my $stagename (keys %{$this->{spec}->{stages}}) {
    my $stage = $this->{spec}->{stages}->{$stagename};
    my $sname = $stagename;
    $sname =~ s/^[!]//;
    
    foreach my $taskname (keys %$stage) {
      my $taskspec = $stage->{$taskname};
      my $tname = $taskname;
      $tname =~ s/^[!]//;
      
      # -- create the task
      my $task = $artifact->createTaskInStage(
          $context,
          $sname,
          $tname,
          $taskspec->{type},
          $SMake::Model::Const::SOURCE_LOCATION,
          $artifact->getPath(),
          $taskspec->{args});
      if($stagename !~ /^[!]/) {
        $task->appendSource($context, $resource);
      }
      if($taskname =~ /^[!]/) {
        $task->setForceRun($context);
      }

      # -- create the resources
      my $targets = $taskspec->{targets};
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
  }

  # -- task, stage and resource dependencies
  foreach my $stagename (keys %{$this->{spec}->{stages}}) {
    my $stage = $this->{spec}->{stages}->{$stagename};
    $stagename =~ s/^[!]//;
    my $stageobj = $artifact->getStage($stagename);

    foreach my $taskname (keys %$stage) {
      my $taskspec = $stage->{$taskname};
      $taskname =~ s/^[!]//;
      my $taskobj = $stageobj->getTask($taskname);

      # -- resource dependencies
      my $sources = $taskspec->{sources};
      if(defined($sources)) {
        foreach my $resname (@$sources) {
          $taskobj->appendSource($context, getDirectResource($artifact, $resname));
        }
      }
    }
  }
    
#    # -- create the task
#    my $task = $artifact->createTaskInStage(
#        $context,
#        $stagename,
#        createTaskName($stagename),
#        $this->{tasktype},
#        $SMake::Model::Const::SOURCE_LOCATION,
#        $artifact->getPath(),
#        { translator => 
#              SMake::Executor::Translator::Compositor->new(1, @{$stage->{command}}) });
#
#    # -- create the resources
#    my $targets = $stage->{targets};
#    if(defined($targets)) {
#      foreach my $resname (@$targets) {
#        my $respath = $resname;
#        $respath =~ s/^[!]//;
#        
#        # -- create the resource
#        my $tgres = $artifact->createProductResource(
#            $context,
#            $SMake::Model::Const::SOURCE_RESOURCE,
#            SMake::Data::Path->new($respath),
#            $task);
#        
#        # -- resolve the resource
#        if($resname !~ /^[!]/) {
#          $queue->pushResource($tgres);
#        }
#      }
#    }
#  }
#  
#  # -- stage and task dependencies
#  foreach my $stagename (keys %{$this->{spec}->{stages}}) {
#    my $stage = $this->{spec}->{stages}->{$stagename};
#    my $task = $artifact->getStage($stagename)->getTask(createTaskName($stagename));
#
#    # -- resource dependencies
#    my $sources = $stage->{sources};
#    if(defined($sources)) {
#      foreach my $resname (@$sources) {
#        $task->appendSource($context, getDirectResource($artifact, $resname));
#      }
#    }
#    
#    # -- dependency specification
#    my $deps = $stage->{deps};
#    if(defined($deps)) {
#      foreach my $dep (@$deps) {
#        my ($deptype, $instmodule, $depspec) = @$dep;
#        my $deplist = $artifact->appendDependencySpecs(
#            $context, $SMake::Parser::Parser::SUBSYSTEM, $deptype, [$depspec]);
#        $task->appendDependency($context, $deplist->[0], $instmodule);
#      }
#    }
#  }  
#  
#  # -- register main resources
#  foreach my $mainname (keys %{$this->{spec}->{main}}) {
#    my $resname = $this->{spec}->{main}->{$mainname};
#    $artifact->appendMainResource(
#        $context, $mainname, getDirectResource($artifact, $resname));
#  }
}

return 1;
