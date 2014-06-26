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

# Create new dependency object
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Model::Object->new(), $class);
  
  return $this;
}

# Create a string which can be used as a hash key (static)
#
# Usage: createKey($type, $project, $artifact, $main)
#    type ...... type of the dependency
#    project ... name of the project
#    artifact .. name of the artifact
#    main ...... type of the main resource
sub createKey {
  my ($type, $project, $artifact, $main) = @_;
  return "$type/$project/$artifact" . (($main)?"/$main":"");
}

# Get a string which can be used as a hash key
sub getKey {
  my ($this) = @_;
  return createKey(
      $this->getDependencyType(),
      $this->getDependencyProject(),
      $this->getDependencyArtifact(),
      $this->getDependencyMainResource()); 
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

# Get type of the references main resource
#
# Usage: name of the type or undef if the default main resource should be used
sub getDependencyMainResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Get model objects addressed by this dependency object
#
# Usage: getObjects($reporter, $subsystem, $repository)
# Returns: ($project, $artifact, $resource)
sub getObjects {
  my ($this, $reporter, $subsystem, $repository) = @_;
  
  my $project = $repository->getProject($this->getDependencyProject());
  if(!defined($project)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "unknown dependent project '%s'",
        $this->getDependencyProject());
  }
    
  my $artifact = $project->getArtifact($this->getDependencyArtifact());
  if(!defined($artifact)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "unknown dependent artifact '%s' in the project '%s'",
        $this->getDependencyProject(),
        $this->getDependencyArtifact());
  }
  
  my $restype = $this->getDependencyMainResource();
  my $resource;
  if(!defined($restype)) {
    $resource = $artifact->getDefaultMainResource();
  }
  else {
    $resource = $artifact->getMainResource($restype);
  }
  if(!defined($resource)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "unknown dependent main resource '%s' of the artifact '%s' in the project '%s'",
        (defined($restype)?$restype:"default"),
        $this->getDependencyProject(),
        $this->getDependencyArtifact());
  }

  return ($project, $artifact, $resource);
}

return 1;
