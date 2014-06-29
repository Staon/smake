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

# Generic binary resolver
package SMake::Platform::Generic::BinResolver;

use SMake::ToolChain::Resolver::Link;

@ISA = qw(SMake::ToolChain::Resolver::Link);

use SMake::Model::Const;

# Create new binary resolver
#
# Usage: new($osuffix)
#    osuffix ..... suffix of object files (usually ".o")
sub new {
  my ($class, $osuffix) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Link->new(
          '.*', quotemeta($osuffix) . '$', $SMake::Model::Const::BIN_MAIN_TYPE),
      $class);
  return $this;
}

return 1;
