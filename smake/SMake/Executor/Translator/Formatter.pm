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

# List of string values with substituted values
package SMake::Executor::Translator::Formatter;

use SMake::Executor::Translator::Value;

@ISA = qw(SMake::Executor::Translator::Value);

use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new file list translator
#
# The translator expects as the value a container of resources
#
# Usage: new($address, $optional, $fmt, $sort, $mangler)
#    address ..... address of the container
#    optional .... node is optional
#    fmt ......... formatting string:
#                      %n ..... name of the value
#                      %v ..... value
#                      %s ..... system value
#    separator ... separator of items
#    sort ........ sort children according to names
#    mangler ..... optional mangler for system values of resource nodes
sub new {
  my ($class, $address, $optional, $fmt, $separator, $sort, $mangler) = @_;
  my $this = bless(SMake::Executor::Translator::Value->new($address, $optional), $class);
  $this->{fmt} = $fmt;
  $this->{separator} = $separator;
  $this->{sortflag} = $sort;
  $this->{mangler} = $mangler;
  return $this;
}

sub translateValue {
  my ($this, $context, $task, $command, $wd, $value) = @_;
  
  # -- get list of children nodes
  my $nodelist = $value->getChildren();
  if($this->{sortflag}) {
  	$nodelist = [sort {$a->getName() cmp $b->getName()} @$nodelist];
  }
  
  # -- construct text for each node
  my $str = "";
  my $first = 1;
  for my $node (@$nodelist) {
    # -- separator
    if($first) {
      $first = 0;
    }
    else {
      $str .= $this->{separator};
    }
    
    # -- process formatting string
    my $state = 0;
    for my $char (split(//, $this->{fmt})) {
      if($state == 0) {
        # -- ordinary char
        if($char eq "%") {
          $state = 1;
        }
        else {
          $str .= $char;
        }
      }
      elsif($state == 1) {
        # -- control sequence
        if($char eq "n") {
          $str .= $node->getName();
        }
        elsif($char eq "v") {
          $str .= $node->getValue();
        }
        elsif($char eq "s") {
          $str .= $node->getSystemArgument($context, $wd, $this->{mangler});
        }
        elsif($char eq "e") {
          $str .= $node->getShellArgument($context, $wd, $this->{mangler});
        }
        elsif($char eq "%") {
          $str .= $char;
        }
        else {
          die "invalid formatting character '$char'!";
        }
        $state = 0;
      }
    }
  }
  
  return [$str];
}

return 1;
