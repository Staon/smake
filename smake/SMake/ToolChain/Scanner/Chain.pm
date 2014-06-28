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

# Chain of responsibility of source scanners. First scanner, which accepts
# the resource, stops whole processing.
package SMake::ToolChain::Scanner::Chain;

use SMake::ToolChain::Scanner::Container;

@ISA = qw(SMake::ToolChain::Scanner::Container);

# Create new chain scanner
#
# Usage: new($scanner*)
#    scanner .. a scanner of the resources
sub new {
  my $class = shift;
  my $this = bless(SMake::ToolChain::Scanner::Container->new(@_), $class);
  return $this;
}

sub processScanner {
  my ($this, $context, $queue, $artifact, $resource, $task, $scanner) = @_;
  
  my $ret = $scanner->scanSource($context, $queue, $artifact, $resource, $task);
  return ($ret, $ret);
}

return 1;
