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
use SMake::Utils::Dirutils;
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
  	resprefix => SMake::Utils::Stack->new("resource prefix"),
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

# Detect change of a file
#
# Usage: getFileMark($path, $mark)
#    path ..... absolute path of the file (logical path in the repository meaning)
#    mark ..... a decider mark which is checked with current mark. If it's empty or
#               undef, new mark is always got.
# Returns: Undef if the file has not changed. Otherwise, new decider mark.
sub hasChanged {
  my ($this, $path, $mark) = @_;
  return $this->{decider}->hasChanged($this->{repository}, $path, $mark);
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

# Get current description. If the stack is empty, undef is returned.
sub getDescriptionSafe {
  my ($this) = @_;
  if(!$this->{description}->isEmpty()) {
    return $this->{description}->topObject();
  }
  else {
    return undef;
  }
}

# Get path of directory of currently processed description file
sub getCurrentDir {
  my ($this) = @_;
  return $this->getDescription()->getDirectory();
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

# Push current resource prefix (a prefix based on path of current artifact)
sub pushResourcePrefix {
  my ($this, $prefix) = @_;
  $this->{resprefix}->pushObject($prefix);
}

# Pop current resource prefix
sub popResourcePrefix {
  my ($this) = @_;
  $this->{resprefix}->popObject();
}

# Get current resource prefix
sub getResourcePrefix {
  my ($this) = @_;
  return $this->{resprefix}->topObject();
}

return 1;