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

use SMake::Profile::Stack;

# Create new context
#
# Usage: new($reporter, $decider, $repository, $visibility, $profiles)
sub new {
  my ($class, $reporter, $decider, $repository, $visibility, $profiles) = @_;
  return bless({
    reporter => $reporter,
    decider => $decider,
    repository => $repository,
    visibility => $visibility,
    profiles => SMake::Profile::Stack->new($profiles),
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

# Get profiles stack
sub getProfiles() {
  my ($this) = @_;
  return $this->{profiles};
}

# Get configured toolchain
sub getToolChain {
  my ($this) = @_;
  return $this->{repository}->getToolChain();
}

# Get shell runner
sub getRunner {
  my ($this) = @_;
  return $this->{repository}->getToolChain()->getRunner();
}

# Get name mangler
sub getMangler {
  my ($this) = @_;
  return $this->{repository}->getToolChain()->getMangler();
}

return 1;
