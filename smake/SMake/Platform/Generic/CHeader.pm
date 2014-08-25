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

# C header (installation of C headers)
package SMake::Platform::Generic::CHeader;

use SMake::Model::Const;
use SMake::Platform::Generic::Const;
use SMake::Platform::Generic::HeaderScanner;
use SMake::Profile::VarProfile;
use SMake::ToolChain::Resolver::Publish;
use SMake::ToolChain::Resolver::ResourceTrans;

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- resolve file suffixes
  $toolchain->createObject(
      "header_sources",
      SMake::ToolChain::Resolver::ResourceTrans,
      sub { $constructor->appendResolver($_[0]); },
      '^' . quotemeta($SMake::Model::Const::SOURCE_RESOURCE) . '$',
      '[.]h(pp)?$',
      $SMake::Platform::Generic::Const::H_RESOURCE,
      undef,
      undef);

  # -- header resolver
  $toolchain->createObject(
      "header_resolver",
      SMake::ToolChain::Resolver::Publish,
      sub {
        $constructor->appendResolver($_[0]);

        # -- header scanner
        $toolchain->registerFeature(
            [SMake::Platform::Generic::HeaderScanner,
             '^' . $SMake::Platform::Generic::Const::H_RESOURCE . '$'
            ]
        );
      },
      '^' . quotemeta($SMake::Platform::Generic::Const::H_RESOURCE) . '$',
      '.*',
      $SMake::Platform::Generic::Const::HEADER_MODULE,
      $SMake::Platform::Generic::Const::VAR_HEADER_DIRECTORY);
}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- header profile (installation directory)
  $toolchain->registerProfile(
      "header",
      SMake::Profile::VarProfile,
      $SMake::Platform::Generic::Const::VAR_HEADER_DIRECTORY);
}

return 1;
