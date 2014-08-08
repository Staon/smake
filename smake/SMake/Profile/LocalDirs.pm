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

# Append/Prepend directories local to current project
package SMake::Profile::LocalDirs;

use SMake::Profile::NodeProfile;

@ISA = qw(SMake::Profile::NodeProfile);

use SMake::Executor::Command::Group;
use SMake::Executor::Command::Option;
use SMake::Executor::Executor;
use SMake::Model::Const;
use SMake::Utils::Searching;

# Create new profile
#
# Usage: new($cmdmask, $address, $typemask, $resmask, $prepend)
#    cmdmask ..... a regular expression of command type
#    address ..... address of the command node (an SMake::Data::Path object or
#                  appropriately formatted string)
#    typemask..... a regular expression to match type of the external resources
#    resmask ..... a regular expression to match names of external resources
#    prepend ..... if it's true, the paths are prepended
sub new {
  my ($class, $cmdmask, $address, $typemask, $resmask, $prepend) = @_;
  my $this = bless(SMake::Profile::NodeProfile->new($cmdmask, $address), $class);
  $this->{typemask} = $typemask;
  $this->{resmask} = $resmask;
  $this->{prepend} = $prepend;
  return $this;
}

sub modifyNode {
  my ($this, $context, $command, $task, $address, $parent, $node) = @_;
  
  # -- create new group
  $node = $this->createGroupIfNotExists($address, $parent, $node);

  # -- get list of directory locations of external resources which match
  #    the resource mask
  my $srclist = $task->getSources();
  my $pathset = {};
  foreach my $src (@$srclist) {
    my $name = $src->getName();
    if($src->getLocation() eq $SMake::Model::Const::EXTERNAL_LOCATION
       && $src->getType() =~ /$this->{typemask}/
       && $name->isBasepath()
       && $name->asString() =~ /$this->{resmask}/) {
      # -- try to resolve the external resource in the local project
      my ($found, $resolved) = SMake::Utils::Searching::resolveLocal(
          $context, $SMake::Executor::Executor::SUBSYSTEM, $src);
      if($found) {
        my $path = $resolved->getPhysicalPath()->getDirpath();
        $pathset->{$path->hashKey()} = $path;
      }
    }
  }

  # -- append/prepend the options
  my $wd = $task->getWDPhysicalPath();
  foreach my $path (values %$pathset) {
    # -- make short relative path based on the task's working directory
    if(defined($wd)) {
      $path = $path->makeSystemArgument($wd);
    }
    else {
      $path = $path->systemAbsolute();
    }
    
    # -- append/prepend the option
    my $option = SMake::Executor::Command::Option->new($path);
    $node->addChild($option, $this->{prepend});
  }

  return $command;
}

return 1;
