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

# Detection of type of a source file
package SMake::Platform::Generic::Source;

use SMake::Executor::Builder::Empty;
use SMake::Model::Const;
use SMake::ToolChain::Resolver::ResourceTrans;
use SMake::Utils::Masks;

# Usage: register($toolchain, $constructor, $mask, $type)
#    toolchain ...... the platform toolchain
#    constructor .... current constructor
#    mask ........... mask of the name of the source resource
#    type ........... target resource type
sub register {
  my ($class, $toolchain, $constructor, $mask, $type) = @_;
  
  # -- resolve file suffixes
  $toolchain->createObject(
      $mask . "::" . $type . "::source",
      SMake::ToolChain::Resolver::ResourceTrans,
      sub { $constructor->appendResolver($_[0]); },
      SMake::Utils::Masks::createMask($SMake::Model::Const::SOURCE_RESOURCE),
      $mask,
      $type,
      undef,
      undef);
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
      [$SMake::Model::Const::RES_TRANSLATION_TASK, SMake::Executor::Builder::Empty->new()],
  );
}

return 1;
