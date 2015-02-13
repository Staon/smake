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

# Implementation of the dependency object for the file storage
package SMake::Storage::File::Dependency;

use SMake::Model::Dependency;

@ISA = qw(SMake::Model::Dependency);

use SMake::Model::Dependency;
use SMake::Utils::Searching;

# Create new dependency object
#
# Usage: new($repository, $storage, $artifact, $depkind, $deptype, $depprj, $departifact)
#    repository ........ repository
#    storage ........... owner storage
#    artifact .......... owner of the dependency
#    depkind ........... dependency kind ("resource", "stage")
#    deptype ........... type of the dependency
#    depprj ............ name of the dependency project
#    departifact ....... name of the dependency artifact
#    depmain ........... type of the dependency main resource (undef for the default)
sub new {
  my ($class, $repository, $storage, $artifact, $depkind, $deptype, $depprj, $departifact, $depmain) = @_;
  my $this = bless(SMake::Model::Dependency->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{artifact} = $artifact;
  $this->{depkind} = $depkind;
  $this->{deptype} = $deptype;
  $this->{depprj} = $depprj;
  $this->{departifact} = $departifact;
  $this->{depmain} = $depmain;
  
  return $this;
}

sub destroy {
  my ($this) = @_;
  
  $this->{repository} = undef;
  $this->{storage} = undef;
  $this->{artifact} = undef;
}

sub getDependencyKind {
  my ($this) = @_;
  return $this->{depkind};
}

sub getDependencyType {
  my ($this) = @_;
  return $this->{deptype};
}

sub getDependencyProject {
  my ($this) = @_;
  return $this->{depprj};
}

sub getDependencyArtifact {
  my ($this) = @_;
  return $this->{departifact};
}

sub getDependencyMainResource {
  my ($this) = @_;
  return $this->{depmain};
}

sub getDependencyStage {
  my ($this) = @_;
  return $this->{depmain};
}

sub constructClosureKey {
  my ($stage, $resource) = @_;
  
  my $key = $stage->getAddress()->getKey();
  if(defined($resource)) {
    $key .= "/" . $resource->getName()->asString();
  }
  return $key;
}

# Update transitive closure of dependencies by dependent stages and resources
#
# Usage: updateTransitiveClosure($context, $subsystem, \%closure, $artifact, $typemask)
#    context ...... parser/executor context
#    subsystem .... logging subsystem
#    closure ...... a hash table which contains currently known closure.
#        The table contains tuples [$stage, $resource], where the stage is
#        a stage object and the resource is its resource. The resource can
#        be undef for stage dependencies. Keys of the table are keys of the
#        stage concatenated with the resource name, if the resource is defined.
#    artifact ..... base artifact object. Its features defines sets of transitive
#        dependencies.
#    typemask ..... a regular expression which matches needed dependency types
sub updateTransitiveClosure {
  my ($this, $context, $subsystem, $closure, $artifact, $typemask) = @_;
  
  # -- append me into the queue
  my @queue = ();
  if($this->getDependencyType() =~ /$typemask/) {
    my ($depprj, $depart, $depstage, $depres) = $this->getObjects(
        $context, $subsystem);
    push @queue, [$this->getDependencyType(), $depstage, $depres];
  }
  
  # -- resolve transitive dependencies
  while(@queue) {
    my ($deptype, $stage, $resource) = @{shift @queue};
    my $key = constructClosureKey($stage, $resource);
    if(!defined($closure->{$key})) {
      # -- append new part of the closure
      $closure->{$key} = [$stage, $resource];
      
      # -- resolve its transitive dependencies
      my $features = $stage->getArtifact()->getFeatures();
      foreach my $feature (@$features) {
        # -- select dependency list
        my $speclist;
        if(defined($artifact->getActiveFeature($feature->getName()))) {
          $speclist = $feature->getOnDependencies();
        }
        else {
          $speclist = $feature->getOffDependencies();
        }
        
        # -- filter dependency types
        $speclist = [grep { $_->getType() eq $deptype } @$speclist];
        
        # -- append into the queue
        foreach my $spec (@$speclist) {
          my $depspecs = SMake::Utils::Construct::parseDependencySpecs(
              $context, $subsystem, $stage->getProject()->getName(), [$spec->getSpec()]);
          foreach my $depspec (@$depspecs) {
            my ($prj2, $art2, $stage2, $res2) = SMake::Utils::Searching::resolveDependency(
                $context,
                $subsystem,
                @{SMake::Model::Dependency::createKeyTuple(
                    $SMake::Model::Dependency::RESOURCE_KIND,
                    $deptype,
                    @$depspec
                )});
            push @queue, [$deptype, $stage2, $res2];  
          }
        }
      }
    }
  }
}

return 1;
