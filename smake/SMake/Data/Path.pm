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
  return "/" . $this->printableString();
}

sub systemRelative {
  my ($this) = @_;
  # TODO: do some portable solution
  return $this->printableString();
}

# Get a string key to be used as a key in a hash table
sub hashKey {
  my ($this) = @_;
  return $this->printableString();
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

# Get a printable representation of the path
sub printableString {
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

return 1;
