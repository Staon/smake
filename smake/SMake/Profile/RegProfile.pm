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

# Create on-demand a registered profile and redirect the job
package SMake::Profile::RegProfile;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

use SMake::Profile::List;

# Create new container profile
#
# Usage: new($regname, @args)
#    regname ...... name of the registered profile
#    args ......... arguments of the profile
sub new {
  my ($class, $regname, @args) = @_;
  
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{regname} = $regname;
  $this->{args} = \@args;
  return $this;
}

sub redirect {
  my ($this, $context, $func) = @_;
  
  # -- create the profile
  my $profile = $context->getToolChain()->createProfile(
      $this->{regname}, @{$this->{args}});
  &$func($profile);
}

sub projectBegin {
  my ($this, $context, $subsystem, $project) = @_;
  $this->redirect($context, sub { $_[0]->projectBegin($context, $subsystem, $project); });
}

sub projectEnd {
  my ($this, $context, $subsystem, $project) = @_;
  $this->redirect($context, sub { $_[0]->projectEnd($context, $subsystem, $project); });
}

sub artifactBegin {
  my ($this, $context, $subsystem, $artifact) = @_;
  $this->redirect($context, sub { $_[0]->artifactBegin($context, $subsystem, $artifact); });
}

sub artifactEnd {
  my ($this, $context, $subsystem, $artifact) = @_;
  $this->redirect($context, sub { $_[0]->artifactEnd($context, $subsystem, $artifact); });
}

sub modifyResource {
  my ($this, $context, $subsystem, $resource, $task) = @_;
  $this->redirect($context, sub {
     $_[0]->modifyResource($context, $subsystem, $resource, $task); });
}

sub modifyCommand {
  my ($this, $context, $command, $task) = @_;
  $this->redirect($context, sub {
     $_[0]->modifyCommand($context, $command, $task); });
}

sub getVariable {
  my ($this, $context, $name) = @_;
  
  my $value;
  $this->redirect($context, sub {
     $value = $_[0]->getVariable($context, $name); });
  return $value;
}

return 1;
