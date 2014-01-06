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

# Generic description object (the object represents one description SMakefile)
package SMake::Model::Description;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new description object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get parent description
#
# Usage: getParent()
# Returns: the parent or undef
sub getParent {
  SMake::Utils::Abstract::dieAbstract();
}

# Get top parent description object
sub getTopParent {
  my ($this) = @_;
  
  my $d = $this;
  my $next = $d->getParent();
  while(defined($next)) {
    $d = $next;
    $next = $next->getParent();
  }
  return $d;
}

# Get logical path of the description file (inside the repository)
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stored decider mark of the description file
sub getMark {
  SMake::Utils::Abstract::dieAbstract();
}

# Get logical directory which the description file lays in
sub getDirectory {
  my ($this) = @_;
  return $this->getPath()->getDirpath();
}

# Add a child description object
#
# Usage: addChild($description)
sub addChild {
  SMake::Utils::Abstract::dieAbstract();
}

# Add a project, which is specified by this description
#
# Usage: addProject($project)
sub addProject {
  SMake::Utils::Abstract::dieAbstract();
}

# Get list of all succesors and me
#
# Usage: getChildren();
# Returns \@childrens
sub getChildren {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
