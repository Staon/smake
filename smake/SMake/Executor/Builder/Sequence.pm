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

# A sequence of builders
package SMake::Executor::Builder::Sequence;

use SMake::Executor::Builder::Builder;

@ISA = qw(SMake::Executor::Builder::Builder);

# Create new builder sequencer
#
# Usage: new($builder*)
sub new {
  my $class = shift;
  my $this = bless(SMake::Executor::Builder::Builder->new(), $class);
  $this->{builders} = [];
  $this->appendBuilders(@_);
  return $this;
}

# Append builders into the sequence
#
# Usage: appendBuilders($builder*)
sub appendBuilders {
  my $this = shift;
  push @{$this->{builders}}, @_;
}

sub build {
  my ($this, $context, $task) = @_;
  
  my $retval = [];
  foreach my $builder (@{$this->{builders}}) {
    my $commands = $builder->build($context, $task);
    push @$retval, @$commands;
  }
  return $retval;
}

return 1;
