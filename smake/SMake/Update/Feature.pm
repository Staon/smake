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
package SMake::Update::Feature;

use SMake::Model::DepSpec;
use SMake::Update::DepSpec;
use SMake::Update::Table;

# Create new feature object
#
# Usage: new($context, $artifact, $name)
#    context ...... parser context
#    artifact ..... parent artifact object
#    name ......... name of the feature
sub new {
  my ($class, $context, $artifact, $name) = @_;
  my $this = bless({}, $class);
  
  my $feature = $artifact->getObject()->getFeature($name);
  if(defined($feature)) {
    $feature->update();
    
    $this->{onlist} = SMake::Update::Table->new(
        \&SMake::Model::DepSpec::createKey,
        $feature->getOnDependencyKeys());
    $this->{offlist} = SMake::Update::Table->new(
        \&SMake::Model::DepSpec::createKey,
        $feature->getOffDependencyKeys());
  }
  else {
    $feature = $artifact->getObject()->createFeature($name);

    $this->{onlist} = SMake::Update::Table->new(
        \&SMake::Model::DepSpec::createKey, []);
    $this->{offlist} = SMake::Update::Table->new(
        \&SMake::Model::DepSpec::createKey, []);
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
  
  # -- update the on-list
  my ($on_delete, undef) = $this->{onlist}->update($context);
  $this->{feature}->deleteOnDependencies($on_delete);

  # -- update the off-list
  my ($off_delete, undef) = $this->{offlist}->update($context);
  $this->{feature}->deleteOffDependencies($off_delete);
  
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

# Append an on-dependency
#
# Usage: appendOnDependency($context, $type, $spec)
#    context ...... parser context
#    type ......... dependency type
#    spec ......... dependency specification
sub appendOnDependency {
  my ($this, $context, $type, $spec) = @_;
  
  my $depspec = SMake::Update::DepSpec->new(
      $context, $this, $type, $spec, 1);
  $this->{onlist}->addItem($depspec);
  return $depspec;
}

# Append an off-dependency
#
# Usage: appendOffDependency($context, $type, $spec)
#    context ...... parser context
#    type ......... dependency type
#    spec ......... dependency specification
sub appendOffDependency {
  my ($this, $context, $type, $spec) = @_;
  
  my $depspec = SMake::Update::DepSpec->new(
      $context, $this, $type, $spec, 0);
  $this->{offlist}->addItem($depspec);
  return $depspec;
}

return 1;
