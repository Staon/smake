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

# Stack of working directories
package SMake::Parser::Chdir;

use SMake::Utils::Dirutils;

# Create new directory stack
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    stack => [],
  }, $class);
}

sub DESTROY {
  # -- fix current directory to be the same as before creation of the stack
  my ($this) = @_;
  if(@{$this->{stack}}) {
    chdir($this->{stack}->[0]);
  }
}

# Change current directory
#
# Usage: pushDir($context)
# Exception: it dies when the directory cannot be changed
sub pushDir {
  my ($this, $context) = @_;
  
  my $dir = $context->getCurrentDir();
  $dir = $context->getRepository()->getPhysicalPath($dir);
  push @{$this->{stack}}, SMake::Utils::Dirutils::getCwd();
  if(!chdir($dir)) {
    die "it's not possible to change current directory to '$dir'!";
  }
}

# Get back into previous directory
#
# Usage: popDir($context)
# Exception: it dies if the directory cannot be changed
sub popDir {
  my ($this, $context) = @_;
  
  my $dir = pop @{$this->{stack}};
  if(!defined($dir)) {
    die "there is no other directory in the cwd stack!";
  }
  if(!chdir($dir)) {
    die "it's not possible to change current directory to '$dir'!";
  }
}

return 1;
