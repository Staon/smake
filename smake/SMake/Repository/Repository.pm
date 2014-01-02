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
use SMake::Utils::Abstract;

# Create new repository
#
# Usage: new($parent)
#   parent .... Parent repository. Null if the repository is not chained.
sub new {
  my ($class, $parent) = @_;
  return bless({
  	parent => $parent,
  	variants => {},
  	profilefactory => SMake::Model::ProfileFactory->new(),
    profiles => [],
  }, $class);
}

# Destroy the repository (destructor)
sub destroyRepository {
  SMake::Utils::Abstract::dieAbstract();
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

# Get description object
#
# Usage: getDescription($path, $version, $variant)
#    path ...... canonical path of the SMakefile
#    version ... ID of requested version
#    variant ... ID of requested variant
# Returns: the description object or undef, if the SMakefile is not registered yet.
sub getDescription {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new description object
#
# Usage: createDescription($path, $mark)
#    path .... canonical path of the description file
#    mark .... decider's mark of the description file
sub createDescription {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new project object
#
# Usage: createProject($name, $path)
#    name ...... name of the project
#    path ...... canonical path of the project location
sub createProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Accept new project
#
# Usage: acceptProject($project)
#    project ... new project object which was created by the createProject()
sub acceptProject {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
