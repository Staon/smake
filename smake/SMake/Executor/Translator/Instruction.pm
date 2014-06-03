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

# Translator of a generic instruction object
package SMake::Executor::Translator::Instruction;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

# Create new translator object
#
# Usage: new($instruction, args...)
sub new {
  my ($class, $instruction) = splice(@_, 0, 2);
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{instruction} = $instruction;
  $this->{arguments} = [@_];
  return $this;
}

sub translate {
  my ($this, $context, $command, $wd) = @_;
  
  my $i = $this->{instruction}->new(@{$this->{arguments}});
  return [$i];
}

return 1;
