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

# Append/prepend values of an environment variable into specified
# group.
package SMake::Profile::EnvProfile;

use SMake::Profile::NodeProfile;

@ISA = qw(SMake::Profile::NodeProfile);

use SMake::Executor::Command::Option;
use SMake::Executor::Executor;

# Create new profile
#
# Usage: new($cmdmask, $address, $envvar, $prepend)
#    cmdmask ..... a regular expression of command type
#    address ..... address of the command node (an SMake::Data::Path object or
#                  appropriately formatted string)
#    envvar ...... name of the environment variable
#    prepend ..... if it's true, the values are prepended
sub new {
  my ($class, $cmdmask, $address, $envvar, $prepend) = @_;
  my $this = bless(SMake::Profile::NodeProfile->new($cmdmask, $address), $class);
  $this->{envvar} = $envvar;
  $this->{prepend} = $prepend;
  return $this;
}

sub modifyNode {
  my ($this, $context, $command, $task, $address, $parent, $node) = @_;

  # -- create new group
  $node = $this->createGroupIfNotExists($address, $parent, $node);

  # -- get value of the variable
  my $value = $ENV{$this->{envvar}};
  if(defined($value)) {
    my @values = split(/[:;]/, $value);
    foreach my $v (@values) {
      my $option = SMake::Executor::Command::Option->new($v);
      $node->addChild($option, $this->{prepend});
    }
  }

  return $command;
}

return 1;
