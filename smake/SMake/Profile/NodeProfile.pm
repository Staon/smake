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

# A profile which creates (or uses already created) node in logical command
package SMake::Profile::NodeProfile;

use SMake::Profile::CommandProfile;

@ISA = qw(SMake::Profile::CommandProfile);

use SMake::Data::Path;
use SMake::Executor::Executor;
use SMake::Utils::Abstract;

# Create new node profile
#
# Usage: new($cmdmask, $address)
#    cmdmask ..... a regular expression of command type
#    address ..... address of the command node (an SMake::Data::Path object or
#                  appropriately formatted string)
sub new {
  my ($class, $cmdmask, $address) = @_;
  my $this = bless(SMake::Profile::CommandProfile->new($cmdmask), $class);
  $this->{address} = SMake::Data::Path->new($address);
  return $this;
}

sub doJob {
  my ($this, $context, $command, $task) = @_;
  
  # -- search the node
  my $parent = $command->getNode(
      $context, $SMake::Executor::Executor::SUBSYSTEM, $this->{address}->getDirpath());
  my $node = $parent->getChild($this->{address}->getBasename());
  
  return $this->modifyNode($context, $command, $task, $this->{address}, $parent, $node);
}

# Modify logical node
#
# Usage: modifyNode($context, $command, $task, $parent, $node)
#    context .... executor context
#    command .... the logical command
#    task ....... a task object which the command is attached to
#    address .... address of the node
#    parent ..... parent node
#    node ....... the node or undef, if the node doesn't exist
# Returns: modified logical command
sub modifyNode {
  SMake::Utils::Abstract::dieAbstract();
}

# Create new group node if it doesn't exist yet
#
# Usage: createNodeIfNotExists($address, $parent, $node)
#    address .... address of the node
#    parent ..... parent node
#    node ....... the node or undef, if the node doesn't exist
# Returns: the node
sub createGroupIfNotExists {
  my ($this, $address, $parent, $node) = @_;
  
  # -- create new group
  if(!defined($node)) {
    $node = SMake::Executor::Command::Group->new($address->getBasename());
    $parent->putChild($node);
  }
  return $node;
}

return 1;
