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

use SMake::Model::ProfileFactory;

# Create new repository
#
# Usage: new($parent, $storage)
#   parent .... Parent repository. Null if the repository is not chained.
#   storage ... Storage of project data
sub new {
  my ($class, $parent, $storage) = @_;
  return bless({
  	parent => $parent,
  	storage => $storage,
  	variants => {},
  	profilefactory => SMake::Model::ProfileFactory->new(),
    profiles => [],
  }, $class);
}

# Destroy the repository (destructor)
sub destroyRepository {
  my ($this) = @_;
  $this->{storage}->destroyStorage($this);
}

# Create instance of a named profile. If the profile is not found, the parent
# repository is tried.
#
# Usage: createProfile($name, ...)
# Return: the profile
# Exception: it dies if the profile is not known
sub createProfile {
  my ($this, $name, @args) = @_;
  my $profile = $this->{profilefactory}->createProfile($name, @args);
  if(!defined($profile)) {
    if(defined($this->{parent})) {
      $profile = $this->{parent}->createProfile($name, @args);
    }
    else {
      die "unknown profile '$name'!";
    }
  }
  return $profile;
}

# Append a variant object (used from configuration files)
#
# Usage: appendVariant($variant)
sub appendVariant {
  my ($this, $variant) = @_;
  $this->{variants}->{$variant->getName()} = $variant;
}

# Register named profile
#
# Usage: registerProfile($name, $module, ...)
#     name ...... name of the profile
#     module .... name of the profile's module
#     ... and other arguments
sub registerProfile {
  my ($this, $name, $module, @args) = @_;
  $this->{profilefactory}->registerRecord($name, $module, @args);
}

# Append a profile into the repository
#
# Usage: appendProfile($profile, ...)
#     profile ..... the profile object, or profile name
#     ... and other arguments for profile creation
sub appendProfile {
  my ($this, $profile, @args) = @_;
  if(!ref($profile)) {
  	$profile = $this->createProfile($profile, @args);
  }
  push @{$this->{profiles}}, $profile;
}

# Convert a resource location to an absolute physical (filesystem) path
#
# Usage: getPhysicalPath($location)
# Returns: The physical absolute path
sub getPhysicalPath {
  my ($this, $location) = @_;
  return $location->systemAbsolute();
  # TODO: redirect to the source storage
}

# Open transaction of the project storage
#
# Usage: openTransaction()
sub openTransaction {
  my ($this) = @_;
  $this->{storage}->openTransaction($this);
}

# Close currently opened transaction of the project storage
#
# Usage: commitTransaction();
sub commitTransaction {
  my ($this) = @_;
  $this->{storage}->commitTransaction($this); 
}

# Create new description object
#
# Usage: createDescription($path, $mark)
#    path .... logical path of the description file
#    mark .... decider's mark of the description file
sub createDescription {
  my ($this, $path, $mark) = @_;
  return $this->{storage}->createDescription($this, $path, $mark);
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

return 1;
