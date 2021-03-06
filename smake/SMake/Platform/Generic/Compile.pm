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

# A generic compilation task
package SMake::Platform::Generic::Compile;

use SMake::ToolChain::Resolver::Compile;
use SMake::ToolChain::Resolver::Multi;
use SMake::Utils::Masks;

sub register {
  my ($class, $toolchain, $constructor, $tasktype, $stage, $restype, $resmask, @tgrecs) = @_;

  # -- create the multi resolver
  my $multi = $toolchain->createObject(
      $restype . "::" . $resmask . "::resolver",
      SMake::ToolChain::Resolver::Multi,
      sub { $constructor->appendResolver($_[0]); });
  my $resolver = SMake::ToolChain::Resolver::Compile->new(
      SMake::Utils::Masks::createMask($restype),
      $resmask,
      $stage,
      $tasktype,
      @tgrecs,
  );
  $multi->appendResolver($resolver);
  
  return $resolver;
}

sub staticRegister {
  my ($class, $toolchain, $tasktype) = @_;

  # -- nothing to do
}

return 1;
