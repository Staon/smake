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

# Updateable active feature object
package SMake::Update::ActiveFeature;

# Create new feature object
#
# Usage: new($context, $artifact, $name)
#    context ...... parser context
#    artifact ..... parent artifact object
#    name ......... name of the feature
sub new {
  my ($class, $context, $artifact, $name) = @_;
  my $this = bless({}, $class);
  
  my $feature = $artifact->getObject()->getActiveFeature($name);
  if(defined($feature)) {
    $feature->update();
  }
  else {
    $feature = $artifact->getObject()->createActiveFeature($name);
  }
  $this->{artifact} = $artifact;
  $this->{feature} = $feature;
  
  return $this;
}

# Update data of the object
#
# Usage: update($context)
sub update {
  my ($this, $context) = @_;
  
  $this->{artifact} = undef;
  $this->{feature} = undef;
}

# Get the model object
sub getObject {
  my ($this) = @_;
  return $this->{feature};
}

# Get the key tuple
sub getKeyTuple {
  my ($this) = @_;
  return $this->{feature}->getKeyTuple();
}

# Get a string which can be used as a hash key
sub getKey {
  my ($this) = @_;
  return $this->{feature}->getKey();
}

# Get name of the active feature
sub getName {
  my ($this) = @_;
  return $this->{feature}->getName();
}

return 1;
