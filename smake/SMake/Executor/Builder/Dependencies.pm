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

# A composing record which adds task dependencies
package SMake::Executor::Builder::Dependencies;

use SMake::Executor::Builder::Record;

@ISA = qw(SMake::Executor::Builder::Record);

use SMake::Executor::Command::Set;
use SMake::Executor::Executor;

# Create new record
#
# Usage: new($group, $deptype)
#    group ...... name of the command group
#    deptype .... a regular expression which describes type of used dependencies
sub new {
  my ($class, $group, $deptype) = @_;
  my $this = bless(SMake::Executor::Builder::Record->new(), $class);
  $this->{group} = $group;
  $this->{deptype} = $deptype;
  return $this;  
}

sub compose {
  my ($this, $context, $task, $command) = @_;

  # -- construct the group
  my $group = $command->getChild($this->{group});
  if(!defined($group)) {
    $group = SMake::Executor::Command::Set->new($this->{group});
    $command->putChild($group);
  }
  
  # -- append dependencies
  my $list = $task->getDependencies();
  foreach my $dep (@$list) {
    if($dep->getDependencyType() =~ /$this->{deptype}/) {
      my ($depprj, $depart, $stage, $depres) = $dep->getObjects(
          $context, $SMake::Executor::Executor::SUBSYSTEM);
      $group->putChild($this->createResourceNode($context, $depres));
    }
  }
}

# A helper method (static) - create dependency record with only one dependency type
#
# Usage: simpleRecord($group, $deptype)
# Returns: the record
sub simpleRecord {
  my ($group, $deptype) = @_;
  return SMake::Executor::Builder::Dependencies->new(
      $group, '^' . quotemeta($deptype) . '$');
}

return 1;
