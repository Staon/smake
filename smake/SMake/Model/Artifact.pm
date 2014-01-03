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

# Generic artifact interface. An artifact is a product of the smake project
# like a library, binary or a package.
package SMake::Model::Artifact;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Data::Path;
use SMake::Model::Const;
use SMake::Utils::Abstract;
use SMake::Utils::Utils;

# Create new artifact
#
# Usage: new();
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the artifact
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the artifact
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get arguments of the artifact
sub getArguments {
  SMake::Utils::Abstract::dieAbstract();
}

# Get location of the artifact (its directory). The value has meaning in the context
# of the repository.
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get project which the artifact belongs to
sub getProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Attach a description file with the artifact
#
# Usage: attachDescription($description)
sub attachDescription {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new resource
#
# Usage: createResource($prefix, $name)
#    prefix .... relative logical path based on the artifact
#    name ...... name of the resource
#    type ...... type of the resource
sub createResource {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new stage or use already created
#
# Usage: createStage($name)
#    name ...... name of the stage
sub createStage {
  SMake::Utils::Abstract::dieAbstract();
}

# A helper method - append source resources
#
# Usage: appendSourceResources($prefix, \@srclist)
#    prefix .... relative path of the sources based on this artifact
#    srclist ... list of sources (names of resources)
#    reporter .. a reporter
#    subsys .... reporter subsystem
# Returns: undef if everything is OK, name of wrong resource otherwise
sub appendSourceResources {
  my ($this, $prefix, $srclist) = @_;
  return undef if($#$srclist < 0);  # -- optimization

  # -- get the source stage (create new or use an already existing)
  my $stage = $this->createStage($SMake::Model::Const::SOURCE_STAGE);
  
  # -- process the source list
  foreach my $src (@$srclist) {
    my $name = SMake::Data::Path->new($src);
    if(!$name->isBasepath()) {
      return $src;
    }
    
    # -- create resource
    my $resource = $this->createResource(
        $prefix, $name, $SMake::Model::Const::SOURCE_RESOURCE);
  }
  
  return undef;
}

return 1;
