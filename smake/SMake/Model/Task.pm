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

# Generic task interface
package SMake::Model::Task;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;
use SMake::Utils::Print;

# Create new task object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Create key tuple (static)
#
# Usage: createKeyTuple($name)
sub createKeyTuple {
  return [$_[0]];
}

# Create string key
#
# Usage: createKeyTuple($name)
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

# Get name of the task
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get type of the task
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get arguments of the task
#
# The arguments are a hash table with a content which meaning depends on the type
# of the task.
sub getArguments {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stage which the task belongs to
sub getStage {
  SMake::Utils::Abstract::dieAbstract();
}

# Get working path of the task
#
# The path has meaning in the context of the repository
sub getWDPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Set (overwrite) the list of target resources
#
# Usage: setTargets(\@list)
#    list .... list of resource objects
sub setTargets {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of target resources
#
# Usage: getTargets()
# Returns: \@list
sub getTargets {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of names of source resources
#
# Usage: getSourceKeys()
# Returns: \@list of tuples [$type (resource type), $name (resource name)]
sub getSourceKeys {
  SMake::Utils::Abstract::dieAbstract();
}

# Delete list of source resources
#
# Usage: deleteSources(\@list)
#    list .... list of tuples [$type, $name]
sub deleteSources {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of source resources
#
# Usage: getSources()
# Returns: \@list
sub getSources {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new source timestamp
#
# Usage: createSourceTimestamp($resource)
# Returns: the timestamp
sub createSourceTimestamp {
  SMake::Utils::Abstract::dieAbstract();
}

# Get source timestamp object
#
# Usage: getSourceTimestamp($type, $name)
#    type .... resource type
#    name .... name (relative path) of the timestamp's resource
sub getSourceTimestamp {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of source timestamps
#
# Usage: getSourceTimestamp()
# Returns: \@list
sub getSourceTimestamps {
  SMake::Utils::Abstract::dieAbstract();
}

# Set map of dependency objects
#
# Usage: setDependencyMap(\%map)
#    map ..... map of (key => dep_object)
sub setDependencyMap {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of external dependencies
#
# Returns: \@list
sub getDependencies {
  SMake::Utils::Abstract::dieAbstract();
}

# Get a printable representation of the task's key
sub printableKey {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of ids of tasks which this is dependent on
#
# Usage: getDependentTasks($reporter, $subsystem)
#    reporter .... a reporter object
#    subsystem ... logging subsystem
# Returns: \@list of task ids
sub getDependentTasks {
  SMake::Utils::Abstract::dieAbstract();
}

# Set force running mode
#
# Usage: setForceRun($flag)
sub setForceRun {
  SMake::Utils::Abstract::dieAbstract();
}

# Does the task forced to be run?
#
# Usage: isForceRun()
# Returns: true if the task must be always run even though no resources have changed.
sub isForceRun {
  SMake::Utils::Abstract::dieAbstract();
}

# Print content of the object
#
# Usage: prettyPrint($indent)
sub prettyPrint {
  my ($this, $indent) = @_;
  
  print ::HANDLE "Task(" . $this->getName() . ") {\n";
  
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "type: " . $this->getType() . "\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "wd: " . $this->getWDPath()->asString() . "\n";

  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "force_run: " . $this->isForceRun() . "\n";
  
  # -- target resources
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "targets: {\n";
  my $targets = $this->getTargets();
  foreach my $target (@$targets) {
    SMake::Utils::Print::printIndent($indent + 2);
    $target->prettyPrint($indent + 2);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";
  
  # -- source timestamps
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "sources: {\n";
  my $sources = $this->getSourceTimestamps();
  foreach my $source (@$sources) {
    SMake::Utils::Print::printIndent($indent + 2);
    $source->prettyPrint($indent + 2);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";
  
  # -- dependencies
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "dependencies: {\n";
  my $deps = $this->getDependencies();
  foreach my $dep (@$deps) {
    SMake::Utils::Print::printIndent($indent + 2);
    $dep->prettyPrint($indent + 2);
    print ::HANDLE "\n";
  }
  SMake::Utils::Print::printIndent($indent + 1);
  print ::HANDLE "}\n";
  
  SMake::Utils::Print::printIndent($indent);
  print ::HANDLE "}";
}

return 1;
