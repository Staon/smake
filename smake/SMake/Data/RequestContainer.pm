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

# Container of requests. This object usually is not used directly but it's
# created inside the appendRequest methods.
package SMake::Data::RequestContainer;

use SMake::Data::Request;

@ISA = qw(SMake::Data::Request);

# Create new request container
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Data::Request->new(), $class);
  $this->{requests} = [];
  return $this;
}

sub appendRequest {
  my ($this, $request) = @_;
  $request->appendToContainer($this);
  return $this;
}

sub appendToContainer {
  my ($this, $cont) = @_;
  for my $request (@{$this->{requests}}) {
    $request -> appendToContainer($cont);
  }
}

sub mergeRequestInternal {
  my ($this, $request) = @_;
  if($request->can('mergeContainer')) {
  	return &{$request->{mergeContainer}}($this);
  }
  else {
  	return $this->mergeSimple($request);
  }
}

sub mergeSimple {
  my ($this, $simple) = @_;
  
  my $changed = 0;
  my $retval = new();
  for my $req (@{$this->{requests}}) {
    my ($c, $nr) = $req->mergeRequestInternal($simple);
    $nr->appendToContainer($retval);
    $changed ||= $c;
  }
  if(!$changed) {
    $simple->appendToContainer($retval);
  }
  
  return (1, $retval);
}

sub mergeContainer {
  my ($this, $cont) = @_;
  
  my $retval = new();
  for my $left (@{$this->{requests}}) {
    my $changed = 0;
    for my $right (@{$cont->{requests}}) {
      my ($c, $nr) = $right->mergeRequestInternal($left);
      $nr->appendToContainer($retval);
      $changed ||= $c;
    }
    if(!$changed) {
      $left->appendToContainer($retval);
    }
  }
  
  return (1, $retval);
}

sub printableString {
  my ($this) = @_;
  my $retval;
  for my $request (@{$this->{requests}}) {
    $retval = $retval . $request->printableString() . ",";
  }
  $retval =~ s/,$//;
  return "(" . $retval . ")";
}

return 1;
