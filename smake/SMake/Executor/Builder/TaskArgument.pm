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

# A composing record which adds values from task's arguments
package SMake::Executor::Builder::TaskArgument;

use SMake::Executor::Builder::Record;

@ISA = qw(SMake::Executor::Builder::Record);

use SMake::Executor::Command::Group;
use SMake::Executor::Command::Option;
use SMake::Executor::Command::Set;
use SMake::Executor::Command::Value;
use SMake::Executor::Executor;
use SMake::Model::Const;
use SMake::Utils::Utils;

# Create new record
#
# Usage: new($group, $arg | \@args, $optional)
#    group ...... name of the command group
#    unique ..... if it's true, duplicities of values are removed
#    option ..... if it's true, option values are inserted (only values). If it's false,
#                 full values (tuples (name, value)) are inserted.
#    args ....... list of names of arguments
#    optional ... if it's true, the argument might not exists
sub new {
  my ($class, $group, $unique, $option, $args, $optional) = @_;
  my $this = bless(SMake::Executor::Builder::Record->new(), $class);
  
  $this->{group} = $group;
  $this->{unique} = $unique;
  $this->{option} = $option;
  if(ref($args) eq "ARRAY") {
    $this->{args} = $args
  }
  else {
    $this->{args} = [$args];
  }
  $this->{optional} = $optional;
    
  return $this;  
}

sub compose {
  my ($this, $context, $task, $command) = @_;

  # -- construct the group
  my $group = $command->getChild($this->{group});
  if(!defined($group)) {
    if($this->{unique}) {
      $group = SMake::Executor::Command::Set->new($this->{group});
    }
    else {
      $group = SMake::Executor::Command::Group->new($this->{group});
    }
    $command->putChild($group);
  }
  
  my $arguments = $task->getArguments();
  foreach my $arg (@{$this->{args}}) {
    # -- get the value
    my $value = $arguments->{$arg};
    if(!$this->{optional} && !defined($value)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Executor::Executor::SUBSYSTEM,
          "task '%s' doesn't contain any argument '%s'!",
          $task->getName(),
          $arg);
    }
    if(ref($value) ne "ARRAY") {
      $value = [$value];
    }
    
    # -- insert the values into the group
    foreach my $item (@$value) {
      my $node;
      if($this->{option}) {
        $node = SMake::Executor::Command::Option->new($item);
      }
      else {
        $node = SMake::Executor::Command::Value->new($arg, $item);
      }
      $group->addChild($node);
    }
  }
}

return 1;
