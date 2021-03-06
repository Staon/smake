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

# Ignore project specification if the project is already parsed
package SMake::Parser::States::Ignore;

use SMake::Parser::States::State;

@ISA = qw(SMake::Parser::States::State);

# Create new state
#
# Usage: new($rootstate)
sub new {
  my ($class, $root) = @_;
  my $this = bless(SMake::Parser::States::State->new(), $class);
  $this->{root} = $root;
  return $this;
}

sub executeDirective {
  my ($this, $parser, $context, $directive, $line) = splice(@_, 0, 5);
  my $method = $this->normalizeMethod($directive);
  if($method eq "endProject") {
    $parser->switchState($this->{root});
  }
  # else ignore the directive
}

return 1;
