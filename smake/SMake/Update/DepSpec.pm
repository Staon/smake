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

# Updateable feature object
package SMake::Update::DepSpec;

use SMake::Model::DepSpec;

# Create new feature object
#
# Usage: new($context, $feature, $spec, $onflag)
#    context ...... parser context
#    feature ...... feature object of mine
#    spec ......... dependency specification
#    onflag ....... if it's true, this is an on-dependency
sub new {
  my ($class, $context, $feature, $spec, $onflag) = @_;
  my $this = bless({}, $class);

  # -- get the object
  my $depspec;
  if($onflag) {
    $depspec = $feature->getObject()->getOnDependency($spec);
  }
  else {
    $depspec = $feature->getObject()->getOffDependency($spec);
  }
  if(!defined($depspec)) {
    if($onflag) {
      $depspec = $feature->getObject()->createOnDependency($spec);
    }
    else {
      $depspec = $feature->getObject()->createOffDependency($spec);
    }
  }
  else {
    $depspec->update();
  }

  $this->{feature} = $feature;
  $this->{depspec} = $depspec;
  
  return $this;
}

# Update data of the object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;
  
  $this->{feature} = undef;
  $this->{depspec} = undef;
}

# Get the model object
sub getObject {
  my ($this) = @_;
  return $this->{depspec};
}

# Get the key tuple
sub getKeyTuple {
  my ($this) = @_;
  return $this->{depspec}->getKeyTuple();
}

# Get a string which can be used as a hash key
sub getKey {
  my ($this) = @_;
  return $this->{depspec}->getKey();
}

# Get dependency specification
#
# Usage: getSpec($context)
#    context ..... parser context
# Returns: the spec
sub getSpec {
  my ($this, $context) = @_;
  return $this->{depspec}->getSpec();
}

return 1;
