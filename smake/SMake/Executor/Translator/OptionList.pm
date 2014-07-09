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

# List of options from a command group
package SMake::Executor::Translator::OptionList;

use SMake::Executor::Translator::Value;

@ISA = qw(SMake::Executor::Translator::Value);

use SMake::Executor::Executor;

# Create new file list translator
#
# The translator expects as the value a container of resources
#
# Usage: new($address, $prefix, $suffix, $itemprefix, $itemsuffix, $separator)
#    address ..... address of the container
sub new {
  my ($class, $address, $prefix, $suffix, $itemprefix, $itemsuffix, $separator) = @_;
  my $this = bless(SMake::Executor::Translator::Value->new($address), $class);
  $this->{prefix} = $prefix;
  $this->{suffix} = $suffix;
  $this->{itemprefix} = $itemprefix;
  $this->{itemsuffix} = $itemsuffix;
  $this->{separator} = $separator;
  return $this;
}

sub translateValue {
  my ($this, $context, $task, $command, $wd, $value) = @_;
  
  # -- get list of option nodes
  my $optlist = $value->getChildren();
  
  my $str = $this->{prefix};
  my $first = 1;
  foreach my $option (@$optlist) {
    # -- separator
    if($first) {
      $first = 0;
    }
    else {
      $str .= $this->{separator};
    }
    
    # -- item prefix
    $str .= $this->{itemprefix};
    
    # -- option value
    $str .= $option->getValue();
    
    # -- item suffix
    $str .= $this->{itemsuffix};
  }
  $str .= $this->{suffix};
  
  return [$str];
}

return 1;
