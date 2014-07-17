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

# Standard set of compilers
package SMake::Platform::Aveco::Compilers;

use SMake::Platform::Aveco::CCompiler;
use SMake::Platform::Aveco::CXXCompiler;

sub register {
  my ($class, $toolchain, $constructor, $stage) = @_;
  
  $toolchain->registerFeature(SMake::Platform::Aveco::CCompiler, $stage);
  $toolchain->registerFeature(SMake::Platform::Aveco::CXXCompiler, $stage);
}

sub staticRegister {
  # -- nothing to do
}

return 1;
