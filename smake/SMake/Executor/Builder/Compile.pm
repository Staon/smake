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

# Generic compilation builder
package SMake::Executor::Builder::Compile;

use SMake::Executor::Builder::Builder;

@ISA = qw(SMake::Executor::Builder::Builder);

use SMake::Executor::Command::Group;
use SMake::Executor::Command::Option;
use SMake::Executor::Command::Resource;
use SMake::Executor::Command::Set;
use SMake::Executor::Const;
use SMake::Model::Const;

# Create new compilation builder
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Executor::Builder::Builder->new(), $class);
  
  return $this;
}

sub build {
  my ($this, $context, $task) = @_;
  
  my $command = SMake::Executor::Command::Set->new($task->getType());
  
  # -- target resources
  my $production = SMake::Executor::Command::Group->new(
      $SMake::Executor::Const::PRODUCT_GROUP);
  $command->putChild($production);
  foreach my $resource (@{$task->getTargets()}) {
    $production->appendChild($this->createResourceNode($context, $resource));
  }
  
  # -- source resources
  my $sources = SMake::Executor::Command::Group->new(
      $SMake::Executor::Const::SOURCE_GROUP);
  $command->putChild($sources);
  foreach my $resource (@{$task->getSources()}) {
  	my $restype = $resource->getType();
    if($restype eq $SMake::Model::Const::SOURCE_RESOURCE
       || $restype eq $SMake::Model::Const::PRODUCT_RESOURCE) {
      $sources->appendChild($this->createResourceNode($context, $resource));
    }
  }
  
  return [$command];
}

return 1;
