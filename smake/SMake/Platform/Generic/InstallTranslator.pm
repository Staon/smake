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

# Generic compile translator - it checks timestamps before the action
# and it stores timestamps after the action
package SMake::Platform::Generic::InstallTranslator;

use SMake::Executor::Translator::Sequence;

@ISA = qw(SMake::Executor::Translator::Sequence);

use SMake::Executor::Instruction::Install;
use SMake::Executor::Translator::Instruction;

# Create new install translator
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Executor::Translator::Sequence->new(
      SMake::Executor::Translator::Instruction->new(
          SMake::Executor::Instruction::Install),
  ), $class);
}

return 1;
