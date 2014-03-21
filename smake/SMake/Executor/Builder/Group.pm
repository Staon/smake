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

# A group builder. The builder selects registered builders according to type
# of the task.
package SMake::Executor::Builder::Group;

use SMake::Executor::Builder::Builder;

@ISA = qw(SMake::Executor::Builder::Builder);

use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new group builder
#
# Usage: new([tasktype, builder]*)
sub new {
  my $class = shift;
  my $this = bless(SMake::Executor::Builder::Builder->new(), $class);
  $this->{builders} = {};
  $this->appendBuilders(@_);
  return $this;
}

# Append one or more new builders
#
# Usage: appendBuilders([tasktype, builder]*)
sub appendBuilders {
  my $this = shift;
  foreach my $tuple (@_) {
    $this->{builders}->{$tuple->[0]} = $tuple->[1];
  }
}

# Build command tree for specified task
#
# Usage: build($context, $task)
#    context ..... executor context
#    task ........ the task
# Returns: \@commands ... list of constructed abstract commands
sub build {
  my ($this, $context, $task) = @_;
  
  # -- search for the builder
  my $builder = $this->{builders}->{$task->getType()};
  if(!defined($builder)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "there is no registered builder for a task of type %s!",
        $task->getType());
  }

  # -- build the command
  return $builder->build($context, $task);
}

return 1;
