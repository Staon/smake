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
# Usage: new($reporter, $repository)
sub new {
  my ($class, $reporter, $repository) = @_;
  return bless({
    reporter => $reporter,
    repository => $repository,
  }, $class);
}

# Get the reporter
sub getReporter() {
  my ($this) = @_;
  return $this->{reporter};
}

# Get the repository
sub getRepository() {
  my ($this) = @_;
  return $this->{repository};
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

return 1;
