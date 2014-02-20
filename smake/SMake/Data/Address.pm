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

# Address of a stage
package SMake::Data::Address;

# Create new address
#
# Usage: new($project, $artifact, $stage)
sub new {
  my ($class, $project, $artifact, $stage) = @_;
  return bless({
    project => $project,
    artifact => $artifact,
    stage => $stage,
  }, $class);
}

# Get a string which can be used as a key
sub getKey {
  my ($this) = @_;
  return $this->{project} . "/" . $this->{artifact} . "/" . $this->{stage};
}

# Get project name
sub getProject {
  my ($this) = @_;
  return $this->{project};
}

# Get name of the artifact
sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

# Get name of the stage
sub getStage {
  my ($this) = @_;
  return $this->{stage};
}

# Compare two addresses for equality
sub isEqual {
  my ($this, $address) = @_;
  return ($this->{project} eq $address->{project})
      && ($this->{artifact} eq $address->{artifact})
      && ($this->{stage} eq $address->{stage});
}

# Get a printable string of the address
sub printableString {
  my ($this) = @_;
  return $this->getKey();
}

# Get model objects addressed by this object
#
# Usage: getObjects($reporter, $subsystem, $repository)
# Returns: ($project, $artifact, $stage)
sub getObjects {
  my ($this, $reporter, $subsystem, $repository) = @_;
  
  # -- get project
  my $project = $repository->getProject($this->{project});
  if(!defined($project)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "project '%s' is not known", $this->{project});
  }
  
  # -- get artifact
  my $artifact = $project->getArtifact($this->{artifact});
  if(!defined($artifact)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "artifact '%s' is not defined in the project '%s'",
        $this->{artifact},
        $this->{project});
  }
  
  # -- get stage
  my $stage = $artifact->getStage($this->{stage});
  if(!defined($stage)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "stage '%s' is not defined in the artifact '%s' of the project '%s'",
        $this->{stage},
        $this->{artifact},
        $this->{project});
  }
  
  return ($project, $artifact, $stage);
}

return 1;
