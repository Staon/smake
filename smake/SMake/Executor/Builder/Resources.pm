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

# A composing record which adds resources into a group
package SMake::Executor::Builder::Resources;

use SMake::Executor::Builder::Record;

@ISA = qw(SMake::Executor::Builder::Record);

use SMake::Executor::Command::Group;
use SMake::Model::Const;

# Create new record
#
# Usage: new($target, $group, $restype, $resmask)
#    target ..... if it's true, the target resources are searched. The source
#                 resources are seachred otherwise.
#    group ...... name of the command group
#    restype .... a regular expression which defines types of added resources
#    resmask .... a regular expression which defines resource names
sub new {
  my ($class, $target, $group, $restype, $resmask) = @_;
  my $this = bless(SMake::Executor::Builder::Record->new(), $class);
  $this->{target} = $target;
  $this->{group} = $group;
  $this->{restype} = $restype;
  $this->{resmask} = $resmask;
  return $this;  
}

sub compose {
  my ($this, $context, $task, $command) = @_;

  # -- get list of resources  
  my $list;
  if($this->{target}) {
    $list = $task->getTargets();
  }
  else {
    $list = $task->getSources();
  }

  # -- construct the group
  my $group = $command->getChild($this->{group});
  if(!defined($group)) {
    $group = SMake::Executor::Command::Group->new($this->{group});
    $command->putChild($group);
  }
  
  # -- append resources
  foreach my $resource (@$list) {
    my $restype = $resource->getType();
    my $resname = $resource->getName()->asString();
    if($restype =~ /$this->{restype}/ && $resname =~ /$this->{resmask}/) {
      $group->appendChild($this->createResourceNode($context, $resource));
    }
  }
}

# Helper method (static)
#
# Create resource record for source resources
#
# Usage: sourceResources($group, $restype)
#    group ..... name of the group
#    restype ... name of type of source resources
# Returns: the record
sub sourceResources {
  my ($group, $restype) = @_;
  
  return SMake::Executor::Builder::Resources->new(
      0,
      $group,
      '^' . quotemeta($restype) . '$',
      '.*'
  );
}

# Helper method (static)
#
# Create resource record for target resources
#
# Usage: targetResources($group, $restype)
#    group ..... name of the group
#    restype ... name of type of source resources
# Returns: the record
sub targetResources {
  my ($group, $restype) = @_;
  
  return SMake::Executor::Builder::Resources->new(
      1,
      $group,
      '^' . quotemeta($restype) . '$',
      '.*'
  );
}

return 1;
