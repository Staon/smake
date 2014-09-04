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

# A generic dependency installation. The feature installs dependency files in
# in a specified stage
package SMake::Platform::Generic::DepInstall;

use SMake::ToolChain::Resolver::DepInstall;
use SMake::ToolChain::Resolver::DepResource;
use SMake::ToolChain::Resolver::Multi;
use SMake::Utils::Masks;

sub register {
  my ($class, $toolchain, $constructor, $deptype, $mainres, $stage, $installdep, $module) = @_;

  # -- multi resolver for specified dependency type
  my $multi = $toolchain->createObject(
      $deptype . "::dep_resolver",
      SMake::ToolChain::Resolver::Multi,
      sub { $constructor->appendResolver($_[0]); },
  );

  # -- resource dependency 
  my $depres = SMake::ToolChain::Resolver::DepResource->new(
      SMake::Utils::Masks::createMask($deptype),
      $mainres);
  $multi->appendResolver($depres);

  # -- dependency on the installation stage
  my $depinst = SMake::ToolChain::Resolver::DepInstall->new(
      SMake::Utils::Masks::createMask($deptype),
      $stage,
      $mainres,
      $installdep,
      $module);
  $multi->appendResolver($depinst);

  return $depres, $depinst;
}

sub staticRegister {
  my ($class, $toolchain, $tasktype) = @_;

  # -- nothing to do
}

return 1;
