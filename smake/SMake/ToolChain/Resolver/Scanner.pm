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

# This resolver pushes a resource scanner object
package SMake::ToolChain::Resolver::Scanner;

use SMake::ToolChain::Resolver::Resource;

@ISA = qw(SMake::ToolChain::Resolver::Resource);

use SMake::Model::Const;
use SMake::ToolChain::Constructor::Constructor;
use SMake::Utils::Masks;

# Create new resolver
#
# Usage: new($type, $file, $tasktype, $restype, $mangler, $scanner, @args)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    tasktype .. type of the task which creates the scanned resource
#    restype ... type of the scanned resource
#    mangler ... mangler to create name of the scanned resource from currently resolved resource
#    scanner ... name of the scanner module
#    args ...... arguments of the scanner
sub new {
  my ($class, $type, $file, $tasktype, $restype, $mangler, $scanner, @args) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Resource->new($type, $file), $class);
  $this->{tasktype} = $tasktype;
  $this->{restype} = $restype;
  $this->{mangler} = $mangler;
  $this->{scanner} = $scanner;
  $this->{args} = [@args];
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  # -- create the scanner
  my $taskmask = SMake::Utils::Masks::createMaskOptional($this->{tasktype});
  my $restype = SMake::Utils::Masks::createMaskOptional($this->{restype});
  my $resname = SMake::Utils::Masks::createMask($context->getMangler()->mangleName(
          $context, $this->{mangler}, $resource->getName())->asString()); 
      '^' 
      . quotemeta($context->getMangler()->mangleName(
          $context, $this->{mangler}, $resource->getName())->asString())
      . '$';
  my $scanner = $this->{scanner}->new($taskmask, $restype, $resname, @{$this->{args}});
  
  # -- push the scanner into the list of scanners
  $context->pushScanner($scanner);
}

return 1;
