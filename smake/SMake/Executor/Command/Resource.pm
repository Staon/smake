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

sub getName {
  my ($this) = @_;
  return $this->{path}->asString();
}

# Get the resource path (absolute filesystem path)
sub getPath {
  my ($this) = @_;
  return $this->{path};
}

# Get value of the node as a system argument
#
# Usage: getSystemArgument($context, $wd, $mangler)
#    context ...... executor context
#    wd ........... task's working directory (absolute filesystem path). It can be
#                   null => full resource path is used.
#    mangler ...... resource name mangler description. It can be null => name is
#                   not mangled.
# Returns: the argument string
sub getSystemArgument {
  my ($this, $context, $wd, $mangler) = @_;
  
  my $path = $this->getPath();
  my $relpath;
  if(defined($wd)) {
    ($relpath, $path) = $path->systemArgument($wd);
  }
  else {
    $relpath = 0;
  }
  
  # -- mangle the filename
  if(defined($mangler)) {
    $path = $context->getMangler()->mangleName($context, $mangler, $path);
  }
  
  # -- construct string filesystem path
  if($relpath) {
    return $path->systemRelative();
  }
  else {
    return $path->systemAbsolute();
  }
}

return 1;
