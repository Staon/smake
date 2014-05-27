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
  	$this = [@{$_[0]}];
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

# Make a relative filesystem path
sub systemRelative {
  my ($this) = @_;
  # TODO: do some portable solution
  return $this->asString();
}

# The method creates a filesystem path based on a specified working directory.
# It tries to make a relative path. If the relative path is too long, system
# absolute path is created instead of. This path must be an absolute directory
# path.
#
# Usage: makeSystemArgument($wd, $basename)
#    wd ......... the working directory
#    basename ... a file basename which is appended to constructed path. It can
#                 be empty to construct only directory path.
# Return: a string which represents the path
sub makeSystemArgument {
  my ($this, $wd, $basename) = @_;
  # TODO: do some portable solution

  # -- search for common prefix
  my $pref = 0;
  while($pref <= $#$this && $pref <= $#$wd && $this->[$pref] eq $wd->[$pref]) {
    ++$pref;
  }
  return $this->systemAbsolute() if($pref == 0);
  
  # -- construct relative path
  my @path = ();
  foreach my $i ($pref .. $#$wd) {
    push @path, "..";
  }
  foreach my $i ($pref .. $#$this) {
    push @path, $this->[$i];
  }
  
  # -- if the relative path is shorter then the absolute, return it
  if($#path < $#$this) {
    my $str = "";
    foreach my $p (@path) {
      $str .= $p . "/";
    }
    $str .= $basename;
    return $str;
  }
  else {
    return $this->systemAbsolute();
  }
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

# Get size of the path
sub getSize {
  my ($this) = @_;
  return $#$this + 1;
}

# Get part of the path at specified index
#
# Usage: getPart($index)
sub getPart {
  my ($this, $index) = @_;
  return $this->[$index];
}

sub printableString {
  my ($this) = @_;
  return $this->asString();
}

return 1;
