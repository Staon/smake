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

# Cache of projects' descriptions
package SMake::Storage::File::Cache;

# Create new cache
#
# Usage: new($size)
#    size ..... maximal number of kept descriptions
sub new {
  my ($class, $size) = @_;
  my $this = bless({
    capacity => $size,
    size => 0,
    data => [],
    refs => [],
    clockhand => 0,
    projects => {},
  }, $class);
}

# Insert a project description into the cache
#
# Usage: insertProject($project)
sub insertProject {
  my ($this, $project) = @_;
  
  my $index;
  if($this->{size} < $this->{capacity}) {
  	# -- there is free space
    $index = scalar @{$this->{data}};
    ++$this->{size};
  }
  else {
    # -- search a project to be removed
    while($this->{refs}->[$this->{clockhand}]) {
      $this->{refs}->[$this->{clockhand}] = 0;
      $this->{clockhand} = ($this->{clockhand} + 1) % $this->{capacity};
    }
    $index = $this->{clockhand};
    delete $this->{projects}->{$this->{data}->[$index]->getKey()};
    $this->{data}->[$index]->destroy();
  }

  # -- insert new project
  $this->{data}->[$index] = $project;
  $this->{refs}->[$index] = 1;
  $this->{projects}->{$project->getKey()} = $index;
}

# Remove a project
#
# Usage: removeProject($key)
sub removeProject {
  my ($this, $key) = @_;
  
  my $index = $this->{projects}->{$key};
  if(defined($index)) {
    $this->{refs}->[$index] = 0;
    $this->{data}->[$index]->destroy();
    delete $this->{projects}->{$key};
  }
}

# Get a project
#
# Usage: getProject($key)
#    key .... key of the project
# Returns: the project or undef
sub getProject {
  my ($this, $key) = @_;
  
  my $index = $this->{projects}->{$key};
  if(defined($index)) {
    $this->{refs}->[$index] = 1;
    return $this->{data}->[$index];
  }
  else {
    return undef;
  }
}

return 1;
