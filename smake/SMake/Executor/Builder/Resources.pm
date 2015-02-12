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

use SMake::Executor::Command::Set;
use SMake::Model::Const;
use SMake::Utils::Masks;

# Create new record
#
# Usage: new($target, $group, $restype, $resmask)
#    target ..... if it's true, the target resources are searched. The source
#                 resources are seachred otherwise.
#    group ...... name of the command group
#    restype .... a regular expression which defines types of added resources
#    resmask .... a regular expression which defines resource names
#    dir ........ use directory paths of the resources
sub new {
  my ($class, $target, $group, $restype, $resmask, $dir) = @_;
  my $this = bless(SMake::Executor::Builder::Record->new(), $class);
  $this->{target} = $target;
  $this->{group} = $group;
  $this->{restype} = $restype;
  $this->{resmask} = $resmask;
  $this->{dirflag} = $dir;
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
    $group = SMake::Executor::Command::Set->new($this->{group});
    $command->putChild($group);
  }
  
  # -- append resources
  foreach my $resource (@$list) {
    my $restype = $resource->getType();
    my $resname = $resource->getName()->asString();
    if($restype =~ /$this->{restype}/ && $resname =~ /$this->{resmask}/) {
      my $resnode;
      if($this->{dirflag}) {
        $resnode = $this->createResourceDirNode($context, $resource);
      }
      else {
        $resnode = $this->createResourceNode($context, $resource);
      }
      $group->putChild($resnode);
    }
  }
}

# Helper method (static)
#
# Create resource record for source resources
#
# Usage: sourceResources($group, $restype, $dir)
#    group ..... name of the group
#    restype ... name of type of source resources
#    dir ....... use directory paths of the resources
# Returns: the record
sub createResourceRecord {
  my ($target, $group, $restype, $dir) = @_;
  
  my $mask;
  if(defined($restype)) {
    if(ref($restype) eq "ARRAY") {
      $maks = SMake::Utils::Masks::createMask(@$restype);
    }
    else {
      $mask = SMake::Utils::Masks::createMask($restype);
    }
  }
  else {
    $mask = '.*';
  }
  return SMake::Executor::Builder::Resources->new($target, $group, $mask, '.*', $dir);
}

# Helper method (static)
#
# Create resource record for source resources
#
# Usage: sourceResources($group, $restype, $dir)
#    group ..... name of the group
#    restype ... name of type of source resources
#    dir ....... use directory paths of the resources
# Returns: the record
sub sourceResources {
  my ($group, $restype, $dir) = @_;
  return createResourceRecord(0, $group, $restype, $dir);
}

# Helper method (static)
#
# Create resource record for target resources
#
# Usage: targetResources($group, $restype, $dir)
#    group ..... name of the group
#    restype ... name of type of source resources
#    dir ....... use directory paths of the resources
# Returns: the record
sub targetResources {
  my ($group, $restype, $dir) = @_;
  return createResourceRecord(1, $group, $restype, $dir);
}

return 1;
