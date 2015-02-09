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

# Generic ant task
package SMake::Platform::Generic::Ant;

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Resources;
use SMake::Executor::Builder::TaskArgument;
use SMake::Executor::Translator::Compositor;
use SMake::Executor::Translator::FileList;
use SMake::Executor::Translator::OptionList;
use SMake::Executor::Translator::ValueList;
use SMake::Platform::Generic::Compile;
use SMake::Platform::Generic::CompileTranslator;
use SMake::Platform::Generic::Const;

sub register {
  my ($class, $toolchain, $constructor) = @_;

}

sub staticRegister {
  my ($class, $toolchain) = @_;

  # -- command builder
  $toolchain->getBuilder()->appendBuilders(
    [$SMake::Platform::Generic::Const::ANT_TASK, SMake::Executor::Builder::Compile->new(
        SMake::Executor::Builder::Resources::sourceResources(
            $SMake::Platform::Generic::Const::SOURCE_GROUP, $SMake::Platform::Generic::Const::ANT_RESOURCE),
        SMake::Executor::Builder::TaskArgument->new(
            $SMake::Platform::Generic::Const::ANT_CMD_GROUP, 0, 1, $SMake::Platform::Generic::Const::ANT_GOALS, 0),
        
    )],
  );

  # -- register command translator
  $toolchain->getTranslator()->appendRecords(
      [$SMake::Platform::Generic::Const::ANT_TASK, SMake::Platform::Generic::CompileTranslator->new(
          SMake::Executor::Translator::Compositor->new(
              1,
              "ant",
              SMake::Executor::Translator::ValueList->new(
                  $SMake::Platform::Generic::Const::ANT_VAR_GROUP, 1, "", "", "-D", "", "=", " ", 0),
              SMake::Executor::Translator::FileList->new(
                  $SMake::Platform::Generic::Const::SOURCE_GROUP, 0, "", "", "-f ", "", " ", 0),
              SMake::Executor::Translator::OptionList->new(
                  $SMake::Platform::Generic::Const::ANT_CMD_GROUP, 0, "", "", "", "", " ", 0),
          ),
      )],
  );
}

return 1;
