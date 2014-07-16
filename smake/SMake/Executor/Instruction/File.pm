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

# File instruction - it creates a file from arguments
package SMake::Executor::Instruction::File;

use SMake::Executor::Instruction::Instruction;

@ISA = qw(SMake::Executor::Instruction::Instruction);

use SMake::Executor::Executor;
use SMake::Utils::Chdir;

# Create new shell instruction
#
# Usage: new($file, $wdir, $separator, \@arguments)
sub new {
  my ($class, $file, $wdir, $separator, $arguments) = @_;
  
  my $this = bless(SMake::Executor::Instruction::Instruction->new(), $class);
  $this->{file} = $file;
  $this->{wdir} = $wdir;
  $this->{separator} = $separator;
  $this->{arguments} = $arguments;
  return $this;
}

sub execute {
  my ($this, $context, $taskaddress, $wdir) = @_;

  # -- prepare current working directory
  my $dirkeeper = $this->pushWD(
      $context, $SMake::Executor::Executor::SUBSYSTEM, $this->{wdir});

  # -- create the target file
  local *FILE;
  open(FILE, ">" . $this->{file});
  foreach my $arg (@{$this->{arguments}}) {
    print FILE $arg;
    print FILE $this->{separator};
  }
  close(FILE);

  # -- change current working directory back
  $this->popWD(
      $context, $SMake::Executor::Executor::SUBSYSTEM, $this->{wdir}, $dirkeeper);
  
  return $SMake::Executor::Instruction::Instruction::NEXT;
}

return 1;
