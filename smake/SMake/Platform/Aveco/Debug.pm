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

# Register generic debug profile
package SMake::Platform::Aveco::Debug;

use SMake::Profile::ValueProfile;

sub register {
  my ($class, $toolchain, $constructor, $mangler) = @_;

  # -- nothing to do
}

sub staticRegister {
  my ($class, $toolchain, $constructor, $taskname) = @_;

  $toolchain->registerProfile(
      "debug",
      SMake::Profile::ValueProfile,
      '^aveco_linker|' 
          . quotemeta($SMake::Model::Const::CXX_TASK)
          . '|'
          . quotemeta($SMake::Model::Const::C_TASK) . '$',
      $SMake::Executor::Const::DEBUG_GROUP,
      1,
      "type");
}

return 1;
