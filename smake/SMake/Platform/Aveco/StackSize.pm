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

# Special translator which sets and computes stacksize and binary's offset
package SMake::Platform::Aveco::StackSize;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

use SMake::Data::Path;
use SMake::Executor::Instruction::Shell;
use SMake::Platform::Aveco::Utils;

# Create new translator
#
# Usage: new($address)
#    address ...... address of the libdirs node
sub new {
  my ($class, $address) = @_;
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{address} = SMake::Data::Path->new($address);
  return $this;
}

sub maximalOffset {
    my ($o1, $o2) = @_;
    if($o1 < $o2) {
        return $o2;
    }
    else {
        return $o1;
    }
}

sub translate {
  my ($this, $context, $task, $command, $wd) = @_;

  # -- get stack size
  my $stacksize = $task->getArguments()->{"stacksize"};
  $stacksize = "32k" if(!defined($stacksize));
  
  # -- get libdirs node
  my $value = $command->getNode(
      $context, $SMake::Executor::Executor::SUBSYSTEM, $this->{address});
  
  # -- compute the code offset
  my $offset = 8 * 1024;
  if(defined($value)) {
    my $children = $value->getChildren();
    foreach my $child (@$children) {
      if($child->getName() =~ /^([^ ]*_s)([.]lib)?$/) {
        if($1 eq "socket_s") {
            $offset = maximalOffset($offset, 5636 * 1024);
        }
        else {
            die "Unknown shared library '$1'";
        }
      }
    }
  }
  $stacksize = SMake::Platform::Aveco::Utils::getSizeNumber($stacksize);
  $offset = $stacksize + $offset;
  $offset = SMake::Platform::Aveco::Utils::roundToMultiple($offset, 4 * 1024);
  
  # -- construct the value
  my $value1 = SMake::Executor::Instruction::Shell->new(
      "OPTION stack=" . int($stacksize / 1024) . "k");
  my $value2 = SMake::Executor::Instruction::Shell->new(
      "OPTION offset=" . int($offset / 1024) . "k");
  return [$value1, $value2];
}

return 1;
