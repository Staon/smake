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

# Append installation directories
package SMake::Profile::InstallPaths;

use SMake::Profile::NodeProfile;

@ISA = qw(SMake::Profile::NodeProfile);

use SMake::Executor::Command::Group;
use SMake::Executor::Command::Option;
use SMake::Executor::Executor;

# Create new profile
#
# Usage: new($cmdmask, $address, $instmodule)
#    cmdmask ..... a regular expression of command type
#    address ..... address of the command node (an SMake::Data::Path object or
#                  appropriately formatted string)
#    instmodule .. installation module
sub new {
  my ($class, $cmdmask, $address, $instmodule) = @_;
  my $this = bless(SMake::Profile::NodeProfile->new($cmdmask, $address), $class);
  $this->{instmodule} = $instmodule;
  return $this;
}

sub modifyNode {
  my ($this, $context, $command, $task, $address, $parent, $node) = @_;

  # -- create new group
  $node = $this->createGroupIfNotExists($address, $parent, $node);
  
  # -- get the path
  my ($restype, $path) = $context->getInstallArea()->getModulePath(
      $context,
      $SMake::Executor::Executor::SUBSYSTEM,
      $this->{instmodule},
      $task->getProject());
  my $fspath = $context->getRepository()->getPhysicalLocationString($restype, $path);
  $node->appendChild(SMake::Executor::Command::Option->new($fspath));

  return $command;
}

return 1;
