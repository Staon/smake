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

# This profile appends/prepends list of options into specified group.
# Optionaly, it can clean previously set options in the group.
package SMake::Profile::ValueProfile;

use SMake::Profile::NodeProfile;

@ISA = qw(SMake::Profile::NodeProfile);

use SMake::Executor::Command::Value;
use SMake::Executor::Executor;

# Create new profile
#
# Usage: new($cmdmask, $address, $clean, $prepend, $options...)
#    cmdmask ..... a regular expression of command type
#    address ..... address of the command node (an SMake::Data::Path object or
#                  appropriately formatted string)
#    clean ....... if it's true, the group is cleaned before the insertion
#    options ..... repeating tuples $name $value
sub new {
  my ($class, $cmdmask, $address, $clean, @options) = @_;
  my $this = bless(SMake::Profile::NodeProfile->new($cmdmask, $address), $class);
  $this->{clean} = $clean;
  
  $this->{options} = [];
  for(my $i = 0; $i <= $#options; $i += 2) {
    my $name = $options[$i];
    my $value = $options[$i + 1];
    push @{$this->{options}}, [$name, $value];
  }
  
  return $this;
}

sub modifyNode {
  my ($this, $context, $command, $task, $address, $parent, $node) = @_;

  # -- create new group
  $node = $this->createSetIfNotExists($address, $parent, $node);
  
  # -- clean the group
  if($this->{clean}) {
    $node->clearSet();
  }

  # -- append/prepend the values
  foreach my $option (@{$this->{options}}) {
    my $child = SMake::Executor::Command::Value->new($option->[0], $option->[1]);
    $node->putChild($child);
  }

  return $command;
}

return 1;
