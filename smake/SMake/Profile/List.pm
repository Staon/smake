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

# List of profiles
package SMake::Profile::List;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

# Create new profile list
#
# Usage: new($profile*)
sub new {
  my ($class, @profiles) = @_;
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{profiles} = [];
  $this->appendProfile(@profiles);
  return $this;
}

# Append a profile into the list
#
# Usage: appendProfile($profile*)
sub appendProfile {
  my ($this, @profiles) = @_;
  push @{$this->{profiles}}, @profiles;
}

sub iterateItems {
  my ($this, $func) = @_;
  
  foreach my $item (@{$this->{profiles}}) {
    &$func($item);
  }
}

sub constructProfiles {
  my ($this, $context, $task) = @_;
  $this->iterateItems(sub { $_[0]->constructProfiles($context, $task); });
}

sub projectBegin {
  my ($this, $context, $subsystem, $project) = @_;
  $this->iterateItems(sub { $_[0]->projectBegin($context, $subsystem, $project); });
}

sub projectEnd {
  my ($this, $context, $subsystem, $project) = @_;
  $this->iterateItems(sub { $_[0]->projectEnd($context, $subsystem, $project); });
}

sub artifactBegin {
  my ($this, $context, $subsystem, $artifact) = @_;
  $this->iterateItems(sub { $_[0]->artifactBegin($context, $subsystem, $artifact); });
}

sub artifactEnd {
  my ($this, $context, $subsystem, $artifact) = @_;
  $this->iterateItems(sub { $_[0]->artifactEnd($context, $subsystem, $artifact); });
}

sub modifyResource {
  my ($this, $context, $subsystem, $resource, $task) = @_;
  $this->iterateItems(sub { $_[0]->modifyResource($context, $subsystem, $resource, $task); });
}

sub modifyCommand {
  my ($this, $context, $command, $task) = @_;

  $this->iterateItems(sub { $command = $_[0]->modifyCommand($context, $command, $task); });
  return $command;
}

sub getVariable {
  my ($this, $context, $name) = @_;
  
  my $value = undef;
  $this->iterateItems(sub {
    my $val = $_[0]->getVariable($context, $name);
    if(defined($val)) {
      $value = $val;
    }
  });
  return $value;
}

return 1;
