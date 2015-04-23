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

# A generic linking task
package SMake::Platform::Generic::Link;

use SMake::ToolChain::Constructor::MainResource;
use SMake::ToolChain::Resolver::Chain;
use SMake::ToolChain::Resolver::Link;
use SMake::ToolChain::Resolver::Multi;

sub register {
  my ($class, $toolchain, $constructor, $stage, $speclist) = @_;

  # -- create the linker resolver for this stage
  my $multi = $toolchain->createObject(
      $stage . "::main_resolver",
      SMake::ToolChain::Resolver::Multi,
      sub { $constructor->appendResolver($_[0]); },
  );
  
  # -- create the chain resolver
  my $chain = SMake::ToolChain::Resolver::Chain->new();
  $multi->appendResolver($chain);

  # -- create main resources (reverse order to be sure the most generic resource is default)
  foreach my $spec (reverse @$speclist) {
    my ($tasktype, $restype, $resmask, $mainres, $tgtype, $tgname, $resolve) = @$spec;

    $toolchain->createObject(
        $mainres . "::main_record",
        SMake::ToolChain::Constructor::MainResource,
        sub { $constructor->appendMainResource($_[0]); },
        $tgtype,
        $mainres,
        $tgname,
        $stage,
        $tasktype,
        $resolve,
        {});
  }
  
  # -- register the linker resolvers
  foreach my $spec (@$speclist) {
    my ($tasktype, $restype, $resmask, $mainres, $tgtype, $tgname, $resolve) = @$spec;

    # -- register the linker resolver
    my $resolver = SMake::ToolChain::Resolver::Link->new(
        $restype,
        $resmask,
        $mainres);
    $chain->appendResolver($resolver);
  }
}

sub staticRegister {
  my ($class, $toolchain, $tasktype) = @_;

  # -- nothing to do
}

return 1;
