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

# Generic resource location object
package SMake::Data::Path;

# Create new resource location object
sub new {
  my $class = shift;
  
  my $this;
  if($#_ == 0 && ref($_[0]) eq $class) {
  	# -- copy ctor
  	$this = [@$_[0]];
  }
  else {
    # -- several arguments => path strings
    $this = [];
    for my $part (@_) {
      my @dirs = split(/\//, $part);
      for my $dir (@dirs) {
        if(!defined($dir) || $dir eq '') {
          die "invalid path part!";
        }
        push @$this, $dir;
      }
    }
  }
  
  return bless($this, $class);
}

# Create new resource location object from a filesystem path
sub fromSystem {
  my ($class, $native) = @_;
  # TODO: do some portable solution
  $native =~ s/^\///;
  return new($class, $native);
}

# Make an absolute filesystem path
sub systemAbsolute {
  my ($this) = @_;
  # TODO: do some portable solution
  return "/" . $this->asString();
}

sub systemRelative {
  my ($this) = @_;
  # TODO: do some portable solution
  return $this->asString();
}

# Get a string key to be used as a key in a hash table
sub hashKey {
  my ($this) = @_;
  return $this->asString();
}

# Check empty path
sub isEmpty {
  my ($this) = @_;
  return $#$this < 0;
}

# Check if the path is a base (only one part)
sub isBasepath {
  my ($this) = @_;
  return $#$this == 0;
}

# Get basename (last part) of the path
sub getBasename {
  my ($this) = @_;
  if($#$this >= 0) {
    return $this->[$#$this];
  }
  else {
    die "empty path has no basename";
  }
}

# Get base path (last part of the path)
sub getBasepath {
  my ($this) = @_;
  my $retval = [$this->getBasename()];
  return bless($retval, ref($this));
}

# Get path one level up
sub getDirpath {
  my ($this) = @_;
  my $retval = [@$this];
  if($#$retval >= 0) {
    pop @$retval;
    return bless($retval, ref($this));
  }
  else {
    die "empty path has no dirname";
  } 
}

# Join several paths
#
# Usage: joinPaths($path|@paths)
sub joinPaths {
  my ($this, @paths) = @_;
  
  my $retval = [@$this];
  foreach my $path (@paths) {
    if(ref($path) ne ref($this)) {
      $path = new(ref($this), $path);
    }
    push @$retval, @$path;
  }
  
  return bless($retval, ref($this));
}

# Get a string representation
sub asString {
  my ($this) = @_;
  if($#$this >= 0) {
    my $str = $this->[0]; 
    foreach my $i (1 .. $#$this) {
      $str .= '/' . $this->[$i];
    }
    return $str;
  }
  else {
    return "";
  }
}

sub printableString {
  my ($this) = @_;
  return $this->asString();
}

return 1;
