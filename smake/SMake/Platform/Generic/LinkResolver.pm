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

# Generic link resolver
package SMake::Platform::Generic::LinkResolver;

use SMake::ToolChain::Resolver::Multi;

@ISA = qw(SMake::ToolChain::Resolver::Multi);

use SMake::Model::Const;
use SMake::ToolChain::Resolver::DepInstall;
use SMake::ToolChain::Resolver::DepResource;

# Create new link resolver
sub new {
  my ($class) = @_;
  
  my $this = bless(
      SMake::ToolChain::Resolver::Multi->new(
          SMake::ToolChain::Resolver::DepResource->new(
              '^' . $SMake::Model::Const::LINK_DEPENDENCY . '$',
              $SMake::Model::Const::BIN_MAIN_TYPE),
          SMake::ToolChain::Resolver::DepInstall->new(
              '^' . $SMake::Model::Const::LINK_DEPENDENCY . '$',
              $SMake::Model::Const::LIB_INSTALL_STAGE,
              $SMake::Model::Const::BIN_MAIN_TYPE,
              $SMake::Model::Const::LIB_MODULE)),
      $class);
  return $this;
}

return 1;
