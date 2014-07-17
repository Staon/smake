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

# Tool chain object. The tool chain is a configuration of used
# build system (compilers, code generators, etc.)
package SMake::ToolChain::ToolChain;

use SMake::Profile::Factory;
use SMake::Profile::List;

# Create new empty tool chain
#
# Usage: new($constructor, $mangler, $builder, $translator, $runner, $scanner, $filter)
#    constructor .. artifact constructor
#    mangler ...... resource name mangler
#    builder ...... builder od abstract commands
#    translator ... a translator of abstract commands to instruction objects
#                   (for example shell commands)
#    scanner ...... source scanner (generator of external resources)
#    filter ....... filter of external resources
sub new {
  my ($class, $constructor, $mangler, $builder, $translator, $scanner, $filter) = @_;
  return bless({
    constructor => $constructor,
    mangler => $mangler,
    builder => $builder,
    translator => $translator,
    scanner => $scanner,
    filter => $filter,
    profilefactory => SMake::Profile::Factory->new(),
    profiles => SMake::Profile::List->new(),
  }, $class);
}

# Get an artifact constructor
#
# Usage: getConstructor()
# Returns: the constructor
sub getConstructor {
  my ($this, $type) = @_;
  return $this->{constructor};
}

# Get name mangler
#
# Usage: getMangler()
# Returns: the mangler
sub getMangler() {
  my ($this) = @_;
  return $this->{mangler};
}

# Get command builder
#
# Usage: getBuilder();
# Returns: the builder
sub getBuilder {
  my ($this) = @_;
  return $this->{builder};
}

# Get command translator
sub getTranslator {
  my ($this) = @_;
  return $this->{translator};
}

# Get source scanner
sub getScanner {
  my ($this) = @_;
  return $this->{scanner};
}

# Get the resource filter
sub getResourceFilter {
  my ($this) = @_;
  return $this->{filter};
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

# Append a compilation profile
#
# Usage: appendProfile($profile)
#    profile ..... the compilation profile
sub appendProfile {
  my ($this, $profile) = @_;
  $this->{profiles}->appendProfile($profile);
}

# Append all toolchain's compilation profiles into a profile stack
#
# Usage: appendToolChainProfiles($profiles)
#    profiles ..... the profile stack
sub appendToolChainProfiles {
  my ($this, $profiles) = @_;
  $profiles->appendProfile($this->{profiles});
}

return 1;
