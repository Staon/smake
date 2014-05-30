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

# Sequence of several scanners
package SMake::Scanner::Sequence;

use SMake::Scanner::Scanner;

@ISA = qw(SMake::Scanner::Scanner);

# Create new sequence scanner
#
# Usage: new($scanner*)
#    scanner ..... a scanner
sub new {
  my $class = shift;
  my $this = bless(SMake::Scanner::Scanner->new(), $class);
  $this->{scanners} = [];
  $this->appendScanners(@_);
  return $this;
}

# Append scanners into the sequence
sub appendScanners {
  my $this = shift;
  push @{$this->{scanners}}, @_;
}

sub scanSource {
  my ($this, $context, $queue, $artifact, $resource, $task) = @_;
  
  foreach my $scanner (@{$this->{scanners}}) {
    $scanner->scanSource($context, $queue, $artifact, $resource, $task);
  }
}

return 1;