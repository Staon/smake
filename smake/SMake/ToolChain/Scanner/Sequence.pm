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

# Sequence of several scanners. All scanners are invoked.
package SMake::ToolChain::Scanner::Sequence;

use SMake::ToolChain::Scanner::Container;

@ISA = qw(SMake::ToolChain::Scanner::Container);

# Create new sequence scanner
#
# Usage: new($scanner*)
#    scanner ..... a scanner
sub new {
  my $class = shift;
  my $this = bless(SMake::ToolChain::Scanner::Container->new(@_), $class);
  return $this;
}

sub processScanner {
  my ($this, $context, $queue, $artifact, $resource, $task, $scanner) = @_;
  return ($scanner->scanSource($context, $queue, $artifact, $resource, $task), 0);
}

return 1;