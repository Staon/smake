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

# An object which describes a dependency of an artifact
package SMake::Model::Dependency;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;
use SMake::Utils::Print;

$RESOURCE_KIND = "resource";
$STAGE_KIND = "stage";

# Create new dependency object
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Model::Object->new(), $class);
  
  return $this;
}

# Create key tuple
#
# Usage: createKey($kind, $type, $project, $artifact, $main/$stage)
#    kind ........ kind of the dependency
#    type ........ type of the dependency
#    project ..... name of the project
#    artifact .... name of the artifact
#    main/stage .. type of the main resource or name of the stage
sub createKeyTuple {
  my ($kind, $type, $project, $artifact, $main) = @_;
  return [$kind, $type, $project, $artifact, $main];
}

# Create a string which can be used as a hash key (static)
#
# Usage: createKey($kind, $type, $project, $artifact, $main)
#    kind ........ kind of the dependency
#    type ...... type of the dependency
#    project ... name of the project
#    artifact .. name of the artifact
#    main ...... type of the main resource
sub createKey {
  my ($kind, $type, $project, $artifact, $main) = @_;
  return "$kind:$type/$project/$artifact" . (($main)?"/$main":"");
}

# Get a string which can be used as a hash key
sub getKeyTuple {
  my ($this) = @_;
  
  my $kind = $this->getDependencyKind();
  if($kind eq $RESOURCE_KIND) {
    return createKeyTuple(
        $this->getDependencyKind(),
        $this->getDependencyType(),
        $this->getDependencyProject(),
        $this->getDependencyArtifact(),
        $this->getDependencyMainResource()); 
  }
  elsif($kind eq $STAGE_KIND) {
    return createKeyTuple(
        $this->getDependencyKind(),
        $this->getDependencyType(),
        $this->getDependencyProject(),
        $this->getDependencyArtifact(),
        $this->getDependencyStage()); 
  }
  else {
    die "wrong dependency kind";
  }
}

# Get a string which can be used as a hash key
sub getKey {
  my ($this) = @_;
  
  my $kind = $this->getDependencyKind();
  if($kind eq $RESOURCE_KIND) {
    return createKey(
        $this->getDependencyKind(),
        $this->getDependencyType(),
        $this->getDependencyProject(),
        $this->getDependencyArtifact(),
        $this->getDependencyMainResource()); 
  }
  elsif($kind eq $STAGE_KIND) {
    return createKey(
        $this->getDependencyKind(),
        $this->getDependencyType(),
        $this->getDependencyProject(),
        $this->getDependencyArtifact(),
        $this->getDependencyStage()); 
  }
  else {
    die "wrong dependency kind";
  }
}

# Get kinf of the dependency (dependency on a main resource, or on a stage)
#
# Usage: getDepedencyKind();
# Returns: "resource" or "stage"
sub getDependencyKind {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the dependency
sub getDependencyType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a name of the project
sub getDependencyProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Get name of the artifact
sub getDependencyArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the references main resource. The value is valid only if
# the dependency is the "resource" kind.
#
# Returns: name of the type or undef if the default main resource should be used
sub getDependencyMainResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get name of dependenc stage. This value is valid only if the dependency
# is the "stage" kind.
sub getDependencyStage {
  SMake::Utils::Abstract::dieAbstract();
}

# Get model objects addressed by this dependency object
#
# Usage: getObjects($context, $subsystem)
# Returns: ($project, $artifact, $stage, $resource)
#    $project ..... dependency project
#    $artifact .... dependency artifact
#    $stage ....... dependency stage
#    $resource .... dependency main resource. It can be undef for stage dependency.
sub getObjects {
  my ($this, $context, $subsystem) = @_;
  
  my $project = $context->getVisibility()->getProject(
      $context, $subsystem, $this->getDependencyProject());
  if(!defined($project)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "unknown dependent project '%s'",
        $this->getDependencyProject());
  }
    
  my $artifact = $project->getArtifact($this->getDependencyArtifact());
  if(!defined($artifact)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "unknown dependent artifact '%s' in the project '%s'",
        $this->getDependencyArtifact(),
        $this->getDependencyProject());
  }
  
  my $kind = $this->getDependencyKind();
  my $stage;
  my $resource;
  if($kind eq $RESOURCE_KIND) {
    # -- dependency on a main resource
    my $restype = $this->getDependencyMainResource();
    if(!defined($restype)) {
      $resource = $artifact->getDefaultMainResource();
    }
    else {
      $resource = $artifact->getMainResource($restype);
    }
    if(!defined($resource)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $subsystem,
          "unknown dependent main resource '%s' of the artifact '%s' in the project '%s'",
          (defined($restype)?$restype:"default"),
          $this->getDependencyProject(),
          $this->getDependencyArtifact());
    }
    $stage = $resource->getStage();
  }
  elsif($kind eq $STAGE_KIND) {
    # -- dependency on a stage
    $stage = $artifact->getStage($this->getDependencyStage());
    if(!defined($stage)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $subsystem,
          "unknown dependent stage '%s' of the artifact '%s' in the project '%s'",
          $this->getDependencyStage(),
          $this->getDependencyProject(),
          $this->getDependencyArtifact());
    }
  }
  else {
    die "invalid dependency kind";
  }

  return ($project, $artifact, $stage, $resource);
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Dependency {\n";

  my $kind = $this->getDependencyKind();
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "kind: $kind\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "type: " . $this->getDependencyType() . "\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "project: " . $this->getDependencyProject() . "\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "artifact: " . $this->getDependencyArtifact() . "\n";

  SMake::Utils::Print::printIndent($indent + 1);
  if($kind eq $RESOURCE_KIND) {
    my $maintype = $this->getDependencyMainResource();
    print ::HANDLE "maintype: " . (defined($maintype)?$maintype:"default") . "\n";
  }
  elsif($kind eq $STAGE_KIND) {
    my $stage = $this->getDependencyStage();
    print ::HANDLE "stage: $stage\n";
  }
  
  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
