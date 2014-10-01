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

# Direct commands
package SMake::Platform::Generic::Direct;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Resources;
use SMake::Executor::Translator::Direct;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;

sub register {
  my ($class, $toolchain, $constructor) = @_;

  # -- nothing to do  
}

sub staticRegister {
  my ($class, $toolchain) = @_;
  
    # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::DIRECT_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP),
        SMake::Executor::Builder::Resources::targetResources(
            $SMake::Platform::Generic::Const::PRODUCT_GROUP),
    )],
  );

  # -- command translator
  $toolchain->getTranslator()->appendRecords([
      $SMake::Platform::Generic::Const::DIRECT_TASK,
      SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Direct->new(),
      ),
  ]);
}

return 1;
