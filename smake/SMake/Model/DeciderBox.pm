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

# Decider box - it keeps all known deciders and allows to compare stored
#   time stamps
package SMake::Model::DeciderBox;

# Create new decider box
#
# Usage: new($default)
#    default .... default decider prefix
sub new {
  my ($class, $default) = @_;
  return bless({
    deciders => {},
    default => $default,
  }, $class);
}

# Register a decider
#
# Usage: registerDecider($prefix, $decider)
#    prefix .... prefix of the marks
#    decider ... the decider object
sub registerDecider {
  my ($this, $prefix, $decider) = @_;
  $this->{deciders}->{$prefix} = $decider;
}

# Check if a file has changed
#
# Usage: isChanged($path, $mark)
#    path .... path to the file
#    mark .... stored decider mark. If the stamp is not known, the mark must
#              contain at least the decider prefix!
# Returns: undef value if the file is not changed, new decider mark if the file
#    is changed.
sub hasChanged {
  my ($this, $path, $mark) = @_;
  
  # parse the mark
  my $prefix;
  my $stored;
  if(!$mark) {
    $prefix = $this->{default};
  }
  elsif($mark =~ /([^:]+):(.*)/) {
  	$prefix = $1;
  	if(!$prefix) {
  	  $prefix = $this->{default};
  	}
  	$stored = $2;
  }
  else {
    die "'$mark' is not a valid decider mark!";
  }

  # -- find the decider  	
  my $decider = $this->{deciders}->{$prefix};
  if(!defined($decider)) {
    die "unknown decider '$prefix'!";
  }
    
  # -- compare the mark
  if($stored) {
    my $current = $decider->getStamp($path);
    if($stored ne $current) {
      return $prefix . ':' . $current;
    }
  }

  return undef;
}

return 1;
