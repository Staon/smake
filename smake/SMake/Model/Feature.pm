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

# Generic feature object
package SMake::Model::Feature;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;
use SMake::Utils::Print;

# Create new feature object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Update attributes of the object
#
# Usage: update()
sub update {
  SMake::Utils::Abstract::dieAbstract();
}

# Create key tuple (static)
#
# Usage: createKeyTuple($name)
sub createKeyTuple {
  return [$_[0]];
}

# Create a string key of the artifact (static)
#
# Usage: createKey($name)
sub createKey {
  return $_[0];
}

sub getKeyTuple {
  my ($this) = @_;
  return createKeyTuple($this->getName());
}

sub getKey {
  my ($this) = @_;
  return createKey($this->getName());
}

# Get name of the feature
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get the project
sub getProject {
  my ($this) = @_;
  return $this->getArtifact()->getProject();
}

# Get the artifact
sub getArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Create on-dependency
#
# Usage: createOnDependency($spec)
#    spec .......... dependency specification
# Returns: the dependency object
sub createOnDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get on-dependency object
#
# Usage: getOnDependency($spec)
#    spec .......... dependency specification
sub getOnDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of keys of on-dependency objects
#
# Usage: getOnDependencyKeys()
# Returns: \@list list of key tuples
sub getOnDependencyKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of on-dependencies
#
# Usage: deleteOnDependencies(\@list)
#    list ...... list of key tuples
sub deleteOnDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of on-dependency specifications
#
# Usage: getOnDependencies()
# Returns: \@list
sub getOnDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Create off-dependency
#
# Usage: createOffDependency($spec)
#    spec .......... dependency specification
# Returns: the dependency object
sub createOffDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get off-dependency object
#
# Usage: getOffDependency($spec)
#    spec .......... dependency specification
sub getOffDependency {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of keys of off-dependency objects
#
# Usage: getOffDependcyKeys()
# Returns: \@list list of key tuples
sub getOffDependencyKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of off-dependencies
#
# Usage: deleteOffDependencies(\@list)
#    list ...... list of key tuples
sub deleteOffDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of off-dependency specifications
#
# Usage: getOffDependencies()
# Returns: \@list
sub getOffDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Feature(" . $this->getName() . ") {\n";
  
  # -- on-dependencies
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "onlist: {\n";
  my $ondeps = $this->getOnDependencies();
  foreach my $ondep (@$ondeps) {
    SMake::Utils::Print::printIndent($indent + 2);
    $ondep->prettyPrint($indent + 1);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";
  
  # -- off-dependencies
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "offlist: {\n";
  my $offdeps = $this->getOffDependencies();
  foreach my $offdep (@$offdeps) {
    SMake::Utils::Print::printIndent($indent + 2);
    $offdep->prettyPrint($indent + 1);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";

  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
