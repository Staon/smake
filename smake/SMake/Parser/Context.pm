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
use SMake::Profile::Stack;
use SMake::Utils::Dirutils;
use SMake::Utils::Stack;

# Create new parser context
#
# Usage: new($reporter, $decider, $repository, $visibility, $profiles)
#    reporter .... reporter object
#    decider ..... decider box
#    repository .. used repository
#    visibility .. projects' visibility object
#    profiles .... stack of compilation profiles
sub new {
  my ($class, $reporter, $decider, $repository, $visibility, $profiles) = @_;
  return bless({
  	reporter => $reporter,
  	decider => $decider,
  	repository => $repository,
  	visibility => $visibility,
  	profiles => SMake::Profile::Stack->new($profiles),
  	currdir => SMake::Utils::Stack->new("currdir"),
  	project => SMake::Utils::Stack->new("project"),
  	artifact => SMake::Utils::Stack->new("artifact"),
  	resprefix => SMake::Utils::Stack->new("resource prefix"),
  	resolver => SMake::Utils::Stack->new("resolver"),
  	scanner => SMake::Utils::Stack->new("scanner"),
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

# Get the visibility object
sub getVisibility {
  my ($this) = @_;
  return $this->{visibility};
}

# Get the toolchain
sub getToolChain {
  my ($this) = @_;
  return $this->{repository}->getToolChain();
}

# Get the name mangler
sub getMangler {
  my ($this) = @_;
  return $this->{repository}->getToolChain()->getMangler();
}

# Get stack of compilation profiles
sub getProfiles {
  my ($this) = @_;
  return $this->{profiles};
}

# Push current directory
sub pushCurrentDir {
  my ($this, $dir) = @_;
  $this->{currdir}->pushObject($dir);
}

sub popCurrentDir {
  my ($this) = @_;
  $this->{currdir}->popObject();
}

# Get path of directory of currently processed description file
sub getCurrentDir {
  my ($this) = @_;
  return $this->{currdir}->topObject();
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
sub getArtifact {
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

# Push new resource resolver
#
# Usage: pushResolver($resolver)
sub pushResolver {
  my ($this, $resolver) = @_;
  $this->{resolver}->pushObject($resolver);
}

# Clear all pushed resource resolvers
sub clearResolvers {
  my ($this) = @_;
  $this->{resolver}->clearStack();
}

# Resolve resource - use all pushed resolvers
#
# Usage: resolveResource($subsystem, $queue, $resource)
#    subsystem ... logging subsystem
#    queue ....... resource queue
#    resource .... resolved resource
# Returns: true if the resource is handled
sub resolveResource {
  my ($this, $subsystem, $queue, $resource) = @_;
  
  my $retval = 0;
  $this->{resolver}->applyFunctor(sub {
    my ($resolver) = @_;
    if($resolver->resolveResource($this, $queue, $resource)) {
      $retval = 1;
      return 1;
    }
    else {
      return 0;
    }
  });
  return $retval;
}

# Resolve dependency record - use all pushed resolvers
#
# Usage: resolveDependency($dependency)
#    dependency .. the dependency object
# Returns: true if the dependency is handled
sub resolveDependency {
  my ($this, $dependency) = @_;

  my $retval = 0;
  $this->{resolver}->applyFunctor(sub {
    my ($resolver) = @_;
    if($resolver->resolveDependency($this, $dependency)) {
      $retval = 1;
      return 1;
    }
    else {
      return 0;
    }
  });
  return $retval;
}

# Push new resource scanner
#
# Usage: pushScanner($scanner)
sub pushScanner {
  my ($this, $scanner) = @_;
  $this->{scanner}->pushObject($scanner);
}

# Clear all pushed scanners
sub clearScanners {
  my ($this) = @_;
  $this->{scanner}->clearStack();
}

# Scan a source file
#
# Usage: scanSource($queue, $task, $resource, $task)
#    queue .......... queue of resources during construction of an artifact
#    artifact ....... resource's artifact
#    resource ....... the scanned resource
#    task ........... a task which the resource is a source for
# Returns: true if the scanner processed the resource
sub scanSource {
  my ($this, $queue, $artifact, $resource, $task) = @_;

  my $retval = 0;
  $this->{scanner}->applyFunctor(sub {
    my ($scanner) = @_;
    if($scanner->scanSource($this, $queue, $artifact, $resource, $task)) {
      $retval = 1;
      return 1;
    }
    else {
      return 0;
    }
  });
  return $retval;
}

return 1;