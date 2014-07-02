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

# Stack of lists of compilation profiles
package SMake::Profile::Stack;

use SMake::Profile::List;

# Create new profiles stack
#
# Usage: new([$parent])
#    parent ..... parent stack
sub new {
  my ($class, $parent) = @_;
  my $this = bless([], $class);
  if(defined($parent)) {
    push @$this, $parent;
  }
  else {
    $this->pushList();  # -- empty stopper
  }
  $this->pushList();
  return $this;
}

# Push new empty list of compilation profiles
#
# Usage: pushList()
sub pushList {
  my ($this) = @_;
  push @$this, SMake::Profile::List->new();
}

# Append a profile into the list at the top
#
# Usage: appendProfile($profile)
sub appendProfile {
  my ($this, $profile) = @_;
  if($#$this < 0) {
    die "empty profile stack!";
  }
  $this->[$#$this]->appendProfile($profile);
}

# Pop top list of compilation profiles
#
# Usage: popList();
sub popList {
  my ($this) = @_;
  my $level = pop @$this;
  if(!defined($level)) {
    die "empty profile stack!";
  }
}

# Create model objects of profile data
#
# Usage: constructProfiles($context, $task)
#    context ..... parser context
#    task ........ a task which the profiles are created for
sub constructProfiles {
  my ($this, $context, $task) = @_;
  
  for(my $index = 1; $index <= $#$this; ++$index) {
    $this->[$index]->constructProfiles($context, $task);
  }
}

return 1;
