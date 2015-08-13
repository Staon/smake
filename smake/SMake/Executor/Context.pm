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

# Executor context
package SMake::Executor::Context;

# Create new context
#
# Usage: new($reporter, $decider, $runner, $repository, $visibility, $mark_cache, $force)
sub new {
  my ($class, $reporter, $decider, $runner, $repository, $visibility, $mark_cache, $force) = @_;
  return bless({
    reporter => $reporter,
    decider => $decider,
    runner => $runner,
    repository => $repository,
    visibility => $visibility,
    force => $force,
    mark_cache => $mark_cache,
  }, $class);
}

# Get the reporter
sub getReporter() {
  my ($this) = @_;
  return $this->{reporter};
}

# Get filestamp decider box
sub getDecider {
  my ($this) = @_;
  return $this->{decider};
}

# Get the repository
sub getRepository() {
  my ($this) = @_;
  return $this->{repository};
}

# Get the visibility object
sub getVisibility {
  my ($this) = @_;
  return $this->{visibility};
}

# Get configured toolchain
sub getToolChain {
  my ($this) = @_;
  return $this->{repository}->getToolChain();
}

# Get shell runner
sub getRunner {
  my ($this) = @_;
  return $this->{runner};
}

# Get name mangler
sub getMangler {
  my ($this) = @_;
  return $this->{repository}->getToolChain()->getMangler();
}

# Check if the force run is set
sub forceRun() {
  my ($this) = @_;
  return $this->{force};
}

# Get the mark cache
sub getMarkCache {
  my ($this) = @_;
  return $this->{mark_cache};
}

return 1;

