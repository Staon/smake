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

# Generic C++ resolver
package SMake::Platform::Generic::CXXResolver;

use SMake::ToolChain::Resolver::Compile;

@ISA = qw(SMake::ToolChain::Resolver::Compile);

# Create new C resolver
#
# Usage: new($osuffix)
#    osuffix .... suffix of object files (usually ".o")
sub new {
  my ($class, $osuffix) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Compile->new(
          '.*', '[.]cpp$', 'Dir() . Name() . "' . $osuffix . '"',
          $SMake::Model::Const::COMPILE_STAGE,
          $SMake::Model::Const::CXX_TASK),
      $class);
  return $this;
}

return 1;
