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

# Resolver of dependencies which appends the dependencies into a main resource
package SMake::ToolChain::Resolver::DepTask;

use SMake::ToolChain::Resolver::Dependency;

@ISA = qw(SMake::ToolChain::Resolver::Dependency);

use SMake::ToolChain::Constructor::Constructor;

# Create new dependency resolver
#
# Usage: new($mask, $task)
#    mask ..... mask of the dependency type
#    task ..... mask of the task type
sub new {
  my ($class, $mask, $task) = @_;
  my $this = bless(SMake::ToolChain::Resolver::Dependency->new($mask), $class);
  $this->{task} = $task;
  return $this;
}

sub doJob {
  my ($this, $context, $dependency) = @_;
  
  # -- attach the dependency to the main resources
  my $artifact = $context->getArtifact();
  my $stages = $artifact->getStages();
  foreach my $stage (@$stages) {
    my $tasks = $stage->getTasks();
    foreach my $task (@$tasks) {
      if($task->getType() =~ /$this->{task}/) {
        $task->appendDependency($context, $dependency, undef);
      }
    }
  }
}

return 1;
