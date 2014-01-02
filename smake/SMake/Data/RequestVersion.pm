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

# Request of a version interval
package SMake::Data::RequestVersion;

use SMake::Data::Request;

@ISA = qw(SMake::Data::Request);

# Create new request
#
# Usage: new(min, max)
#    min ..... minimal version (can be undef)
#    max ..... maximal version (can be undef)
sub new {
  my ($class, $min, $max) = @_;
  my $this = bless(SMake::Data::Request->new(), $class);
  $this->{min} = $min;
  $this->{max} = $max;
  return $this;
}

sub mergeRequestInternal {
  my ($this, $request) = @_;
  if($request->can('mergeVersion')) {
    return &{$request->{mergeVersion}}($this);
  }
  else {
    return (0, $this);
  }
}

sub mergeVersion {
  my ($this, $request) = @_;

  # lo bound
  my $min;
  if(defined($this->{min})) {
    if(defined($request->{min})) {
      $min = ($this->{min}->isLess($request->{min}))?$request->{min}:$this->{min};
    }
    else {
      $min = $this->{min};
    }
  }
  else {
    $min = $request->{min};
  }
  
  # hi bound
  my $max;
  if(defined($this->{max})) {
    if(defined($request->{max})) {
      $max = ($this->{max}->isLess($request->{max}))?$this->{max}:$request->{max};
    }
    else {
      $max = $this->{max};
    }
  }
  else {
    $max = $request->{max};
  }
  
  # create new request
  return (1, new($min, $max));
}

sub printableString {
  my ($this) = @_;
  my $str;
  if(defined($this->{min})) {
    if(defined($this->{max})) {
      if($this->{min}->isEqual($this->{max})) {
        $str = $this->{min}->printableString();
      }
      else {
        $str = $this->{min}->printableString() . "," . $this->{max}->printableString();
      }
    }
    else {
      $str = ">=" . $this->{min}->printableString();
    }
  }
  else {
    if(defined($this->{max})) {
      $str = "<=" . $this->{max}->printableString();
    }
    else {
      $str = "all";
    }
  }
  return "Version[$str]";
}

return 1;
