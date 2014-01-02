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

# Parser context
package SMake::Parser::Context;

use File::Basename;
use SMake::Utils::Stack;

# Create new parser context
#
# Usage: new($reporter, $version, $variant, $project)
#    reporter .... reporter object
#    decider ..... decider box
#    repository .. used repository
sub new {
  my ($class, $reporter, $decider, $repository) = @_;
  return bless({
  	reporter => $reporter,
  	decider => $decider,
  	repository => $repository,
  	description => SMake::Utils::Stack->new("description"),
  	project => SMake::Utils::Stack->new("project"),
  	artifact => SMake::Utils::Stack->new("artifact"),
  }, $class);
}

# Clone the context (shallow copy)
#
# Usage: clone()
sub clone {
  my ($this) = @_;
  return bless({ %$this }, ref($this));
}

# Get the reporter object
sub getReporter {
  my ($this) = @_;
  return $this->{reporter};
}

# Get the decider box
sub getDecider {
  my ($this) = @_;
  return $this->{decider};
}

# Get the repository
sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

# Push current description
#
# Usage: setDescription($description)
sub pushDescription {
  my ($this, $description) = @_;
  $this->{description}->pushObject($description);
}

sub popDescription {
  my ($this) = @_;
  $this->{description}->popObject();
}

# Get current description
sub getDescription {
  my ($this) = @_;
  return $this->{description}->topObject();
}

# Get path of directory of currently processed description file
sub getCurrentDir {
  my ($this) = @_;
  return File::Basename->dirname($this->getDescription()->getPath());
}

# Push current project
#
# Usage: pushProject($project)
sub pushProject {
  my ($this, $project) = @_;
  $this->{project}->pushObject($project);
}

# Pop current project
sub popProject {
  my ($this) = @_;
  $this->{project}->popObject();
}

# Get current project
sub getProject {
  my ($this) = @_;
  return $this->{project}->topObject();
}

# Push current artifact
sub pushArtifact {
  my ($this, $artifact) = @_;
  $this->{artifact}->pushObject($artifact);
}

# Pop current artifact
sub popArtifact {
  my ($this) = @_;
  $this->{artifact}->popObject();
}

# Get current artifact
sub getArtifact() {
  my ($this) = @_;
  return $this->{artifact}->topObject();
}

return 1;