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

# Resource command option
package SMake::Executor::Command::Resource;

use SMake::Executor::Command::Node;

@ISA = qw(SMake::Executor::Command::Node);

use SMake::Utils::PathUtils;

# Create new resource command node
#
# Usage: new($path)
#    path .... absolute filesystem path of the resource
sub new {
  my ($class, $path) = @_;
  my $this = bless(SMake::Executor::Command::Node->new(), $class);
  $this->{path} = $path;
  return $this;
}

# Get the resource path (absolute filesystem path)
sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getName {
  my ($this) = @_;
  return $this->{path}->asString();
}

sub getValue {
  my ($this) = @_;
  return $this->getName();
}

sub getSystemArgument {
  my ($this, $context, $wd, $mangler) = @_;

  return SMake::Utils::PathUtils::getSystemArgument(
      $context, $this->getPath(), $wd, $mangler);  
}

return 1;
