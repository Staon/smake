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

#  Change directory and remember current
package SMake::Utils::Chdir;

use SMake::Utils::Dirutils;

# Create new change directory object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

sub DESTROY {
  my ($this) = @_;
  if(defined($this->{oldpath})) {
    chdir($this->{oldpath});
  }
}

# Change current directory
#
# Usage: pushDir($newpath, $reporter, $subsystem)
sub pushDir {
  my ($this, $newpath, $reporter, $subsystem) = @_;
	
  # -- store old path
  $this->{oldpath} = SMake::Utils::Dirutils::getCwd();
  
  # -- change directory
  if(!chdir($newpath)) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "it's not possible to enter directory %s",
        $newpath);
  }
}

#  Get back into the stored directory
#
#  Usage: popDir($reporter, $subsystem)
sub popDir {
  my ($this, $reporter, $subsystem) = @_;
	
  # -- change directory
  if(!chdir($this->{oldpath})) {
    SMake::Utils::Utils::dieReport(
        $reporter,
        $subsystem,
        "it's not possible to return to directory %s",
        $this->{oldpath});
  }
}

return 1;
