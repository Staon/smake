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

# Implementation of the description object for the file storage
package SMake::Storage::File::Description;

use SMake::Model::Description;

@ISA = qw(SMake::Model::Description);

# Create new description object
#
# Usage: new($repository, $storage, $project, $path, $mark)
#    repository ..... repository object
#    storage ........ owning file storage
#    parent ......... parent description (can be undef for root object)
#    path ........... logical path of the description file
#    mark ........... current decider mark
sub new {
  my ($class, $repository, $storage, $parent, $path, $mark) = @_;
  my $this = bless(SMake::Model::Description->new(), $class);
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  $this->{path} = $path;
  $this->{mark} = $mark;
  $this->{children} = {};
  $this->{projects} = {};
  
  if(defined($parent)) {
    $this->{parent} = $parent->getKey();
    $parent->addChild($this);
  }
  
  return $this;
}

# Create key from atributes (static method)
#
# Usage: createKey($path)
sub createKey {
  my ($path) = @_;
  return $path->hashKey();
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getKey {
  my ($this) = @_;
  return createKey($this->{path});
}

sub getParent {
  my ($this) = @_;
  return $this->{storage}->getDescriptionKey($this->{parent});
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getMark {
  my ($this) = @_;
  return $this->{mark};
}

sub addChild {
  my ($this, $description) = @_;
  $this->{children}->{$description->getKey()} = 1;
}

sub addProject {
  my ($this, $project) = @_;
  $this->{projects}->{$project->getKey()} = 1;
}

sub getChildren {
  my ($this) = @_;
  my @retval = ($this);
  foreach my $dkey (keys %{$this->{children}}) {
    my $desc = $this->{storage}->getDescriptionKey($dkey);
    die "unknown project $prjkey" if(!defined($desc));
    push @retval, @{$desc->getChildren()};
  }
  return \@retval;
}

return 1;
