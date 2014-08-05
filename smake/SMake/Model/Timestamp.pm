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

# Generic timestamp interface - the timestamp keeps info about
# last usage of a resource.
package SMake::Model::Timestamp;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Model::Const;
use SMake::Model::Resource;
use SMake::ToolChain::Decider::DeciderList;
use SMake::Utils::Abstract;
use SMake::Utils::Print;
use SMake::Utils::Searching;
use SMake::Utils::Utils;

# Create new timestamp object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# (static) Create string key
#
# Usage: createKey($type, $name)
sub createKeyTuple {
  return SMake::Model::Resource::createKeyTuple(@_);
}

# (static) Create string key
#
# Usage: createKey($type, $name)
sub createKey {
  return SMake::Model::Resource::createKey(@_);
}

# Get string key
sub getKeyTuple {
  my ($this) = @_;
  return $this->getResource()->getKeyTuple();
}

# Get string key
sub getKey {
  my ($this) = @_;
  return $this->getResource()->getKey();
}

# Get resource type
sub getType {
  my ($this) = @_;
  return $this->getResource()->getType();
}

# Get name of the stamp's resource (relative path)
sub getName {
  my ($this) = @_;
  return $this->getResource()->getName();
}

# Get timestamp mark
#
# Usage: getMark();
sub getMark {
  SMake::Utils::Abstract::dieAbstract();
}

# Update timestamp mark
#
# Usage: updateMark($mark)
sub updateMark {
  SMake::Utils::Abstract::dieAbstract();
}

# Get the resource
sub getResource {
  SMake::Utils::Abstract::dieAbstract();
}

sub resolveExternalResource {
  my ($this, $context, $resource) = @_;
  
  # -- try to search in the 
}

# Compute current stamp of the resource
#
# Usage: computeCurrentStamp($context, $subsystem)
#    context ..... parser or executor context
#    subsystem ... logging subsystem
# Returns: computed resource stamp
sub computeCurrentMark {
  my ($this, $context, $subsystem) = @_;
  
  # -- get set of resources to compute the mark
  my $resource = $this->getResource();
  my $declist = SMake::ToolChain::Decider::DeciderList->new();
  if($resource->getType() eq $SMake::Model::Const::SOURCE_RESOURCE 
     || $resource->getType() eq $SMake::Model::Const::PRODUCT_RESOURCE) {
    $declist->appendPaths($resource->getPhysicalPath());
  }
  elsif($resource->getType() eq $SMake::Model::Const::EXTERNAL_RESOURCE) {
    # -- do transitive closure and compute combined stamp
    my $closure = SMake::Utils::Searching::externalTransitiveClosure(
        $context, $subsystem, $resource);
    foreach my $c (@$closure) {
      $declist->appendPaths($c->[1]->getPhysicalPath());
    }
  }
  elsif($resource->getType() eq $SMake::Model::Const::BUILD_TREE_RESOURCE) {
    # -- the mark is not computed for directories
  }
  else {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "i cannot compute timestamp for resource of type '%s'",
        $resource->getType());
  }
    
  # -- get file timestamp
  return $context->getDecider()->getMark($context->getRepository(), $declist);
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Timestamp(" . $this->getName()->asString() . ") {\n";

  # -- resource
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "resource: ";
  $this->getResource()->prettyPrint($indent + 1);
  print ::HANDLE "\n";

  # -- resource
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "mark: ";
  my $mark = $this->getMark();
  print ::HANDLE (defined($mark)?$mark:"undef");
  print ::HANDLE "\n";
  
  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
