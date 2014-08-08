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

# Generic repository interface
package SMake::Repository::Repository;

use SMake::Model::Resource;
use SMake::Utils::Utils;

# Create new repository
#
# Usage: new($parent, $storage)
#   parent ....... Parent repository. Null if the repository is not chained.
#   storage ...... Storage of project data
#   installarea .. Installation area object
sub new {
  my ($class, $parent, $storage, $installarea) = @_;
  my $this = bless({
  	parent => $parent,
  	storage => $storage,
  	installarea => $installarea,
  	variants => {},
  }, $class);
  
  # -- load storage data
  $storage->loadStorage($this);
  
  return $this;
}

# Destroy the repository (destructor)
sub destroyRepository {
  my ($this) = @_;
  $this->{storage}->destroyStorage($this);
}

# Get used tool chain
#
# Usage: getToolChain()
sub getToolChain {
  my ($this) = @_;
  return $this->{toolchain};
}

# Set the tool chain
#
# Usage: setToolChain($toolchain)
sub setToolChain {
  my ($this, $toolchain) = @_;
  $this->{toolchain} = $toolchain;
}

# Get the installation area
sub getInstallArea {
  my ($this) = @_;
  return $this->{installarea};
}

# Append a variant object (used from configuration files)
#
# Usage: appendVariant($variant)
sub appendVariant {
  my ($this, $variant) = @_;
  $this->{variants}->{$variant->getName()} = $variant;
}

# Check if the source and the product trees are separated. If this method is
# true target (product) directories are created and cleaned with the product
# resources too.
sub isBuildTreeSeparated {
  my ($this) = @_;
  return $this->{storage}->isBuildTreeSeparated();
}

# Get physical location of a resource
#
# Usage: getPhysicalLocation($location, $respath)
#    location ...... resource location type
#    respath ....... a location (a path object) in repository meaning
# Returns: a path object with absolute filesystem path
sub getPhysicalLocation {
  my ($this, $location, $respath) = @_;
  return $this->{storage}->getPhysicalLocation($location, $respath);
}

# Get physical location of a resource
#
# Usage: getPhysicalLocation($location, $respath)
#    location ...... resource location type
#    respath ....... a location (a path object) in repository meaning
# Returns: a string which represents the absolute filesystem path
sub getPhysicalLocationString {
  my ($this, $location, $respath) = @_;
  return $this->getPhysicalLocation($location, $respath)->systemAbsolute();
}

# Convert a physical aboslute location to repository location
#
# Usage: getRepositoryLocation($location, $respath)
#    location ...... resource location type
#    respath ....... a physical location (a path object)
# Returns: a path object with the repository location
sub getRepositoryLocation {
  my ($this, $location, $respath) = @_;
  return $this->{storage}->getRepositoryLocation($location, $respath);
}

# Open transaction of the project storage
#
# Usage: openTransaction()
sub openTransaction {
  my ($this) = @_;
  
  $this->{storage}->openTransaction($this);
  if(defined($this->{parent})) {
    $this->{parent}->openTransaction();
  }
}

# Close currently opened transaction of the project storage
#
# Usage: commitTransaction();
sub commitTransaction {
  my ($this) = @_;
  
  $this->{storage}->commitTransaction($this);
  if(defined($this->{parent})) {
    $this->{parent}->commitTransaction();
  } 
}

# Create new project object
#
# Usage: createProject($name, $path)
#    name ...... name of the project
#    path ...... logical path of the project
sub createProject {
  my ($this, $name, $path) = @_;
  return $this->{storage}->createProject($this, $name, $path);
}

# Get project object
#
# Usage: getProject($name)
#    name .... name of the project
# Returns: ($project, $external)
#    project ..... the project object or undef
#    external .... external flag
sub getProject {
  my ($this, $name) = @_;
  
  # -- try to find locally
  my $project = $this->{storage}->getProject($this, $name);
  if(defined($project)) {
    return $project, 1;
  }
  else {
    # -- use parent repository
    if(defined($this->{parent})) {
      return $this->{parent}->getProject($name);
    }
    else {
      return undef, 1;
    }
  }
}

# Search for a public resource
#
# Usage: searchPublicResource($context, $subsystem, $resource)
#    context ...... parser/executor context
#    subsystem .... logging subsystem
#    resource ..... resource key tuple
# Returns: \@list
#    list ......... list of project key tuples
sub searchPublicResource {
  my ($this, $context, $subsystem, $resource) = @_;
  
  # -- search in my storage
  my $prjlist = $this->{storage}->searchPublicResource($this, $resource);
  return $prjlist if(defined($prjlist));
  
  # -- redirect to the parent
  if(defined($this->{parent})) {
    $prjlist = $this->{parent}->searchPublicResource(
        $context, $subsystem, $resource);
    
    # -- If the resource is found in a parent project, but the project is defined in
    #    this repository, the resource has been removed. We want to detect this
    #    situation and fail the compilation.
    if(defined($prjlist)) {
      foreach my $prj (@$prjlist) {
        if($this->{storage}->projectExists($this, $prj)) {
          SMake::Utils::Utils::dieReport(
              $context->getReporter(),
              $subsystem,
              "external resource '%s' is removed in a nearer repository!",
              SMake::Model::Resource::createKey(@$resource));
        }
      }
    }
    
    return $prjlist;
  }

  return undef;
}

# Get list of overlapped projects
#
# Usage: getOverlappedProjects($name)
#    name ..... name of the projects
# Returns: \@list
#    list ..... list of project objects. First is the most significat, last
#               is the least significant (from the farest repository)
sub getOverlappedProjects {
  my ($this, $name) = @_;
  
  # -- get project of mine
  my $list = [];
  my $project = $this->{storage}->getProject($this, $name);
  if(defined($project)) {
    push @$list, $project;
  }
  
  # -- get project of parent
  if(defined($this->{parent})) {
    my $parentlist = $this->{parent}->getOverlappedProjects($name);
    push @$list, @{$parentlist};
  }
  
  return $list;
}

return 1;
