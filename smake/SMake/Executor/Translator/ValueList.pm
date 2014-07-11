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

# List of named values
package SMake::Executor::Translator::ValueList;

use SMake::Executor::Translator::Value;

@ISA = qw(SMake::Executor::Translator::Value);

use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new file list translator
#
# The translator expects as the value a container of resources
#
# Usage: new($address, $prefix, $suffix, $itemprefix, $itemseparator, $itemsuffix, $separator, $sort)
#    address ..... address of the container
sub new {
  my ($class, $address, $optional, $prefix, $suffix, $itemprefix, $itemsuffix, $itemseparator, $separator, $sort) = @_;
  my $this = bless(SMake::Executor::Translator::Value->new(
      $address, $optional), $class);
  $this->{prefix} = $prefix;
  $this->{suffix} = $suffix;
  $this->{itemprefix} = $itemprefix;
  $this->{itemsuffix} = $itemsuffix;
  $this->{itemseparator} = $itemseparator;
  $this->{separator} = $separator;
  $this->{sortflag} = $sort;
  return $this;
}

sub translateValue {
  my ($this, $context, $task, $command, $wd, $value) = @_;
  
  # -- get list of children nodes
  my $children = $value->getChildren();
  
  # -- create system argument strings
  my $arguments = [];
  foreach my $child (@$children) {
    push @$arguments, $child->getValueArgument($context, $this->{itemseparator});
  }
  
  # -- sort the arguments
  if($this->{sortflag}) {
    $arguments = [sort {$a cmp $b} @$arguments];
  }

  # -- create the command string
  my $str = $this->{prefix};
  my $first = 1;
  foreach my $argument (@$arguments) {
    # -- separator
    if($first) {
      $first = 0;
    }
    else {
      $str .= $this->{separator};
    }
    
    # -- argument
    $str .= $this->{itemprefix};
    $str .= $argument;
    $str .= $this->{itemsuffix};
  }
  $str .= $this->{suffix};
  
  return [$str];
}

return 1;
