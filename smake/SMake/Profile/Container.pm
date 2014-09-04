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

# Generic container profile (a profile which contains other profiles)
package SMake::Profile::Container;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

use SMake::Profile::List;

# Create new container profile
#
# Usage: new(\@profs, \%modulespec, $module...)
#    profs ........ list of profiles which is always applied
#    modulespec ... table of associatives (name => \@profs) (can be undef)
#    module ....... Names of modules. All profiles from the modulespec table
#                   item are inserted into the container too.
sub new {
  my ($class, $profs, $modulespec, @modules) = @_;
  
  my $this = bless(SMake::Profile::Profile->new(), $class);
  
  # -- all children
  $this->{children} = SMake::Profile::List->new(@$profs);
  
  # -- append modules
  if(defined($modulespec)) {
    foreach my $module (@modules) {
      my $spec = $modulespec->{$module};
      if(defined($spec)) {
      	$this->{children}->appendProfile(@$spec);
      }
    }
  }
  
  return $this;
}

sub constructProfiles {
  my ($this, $context, $task) = @_;
  $this->{children}->constructProfiles($context, $task);
}

sub projectBegin {
  my $this = shift;
  $this->{children}->projectBegin(@_);
}

sub projectEnd {
  my $this = shift;
  $this->{children}->projectEnd(@_);
}

sub artifactBegin {
  my $this = shift;
  $this->{children}->artifactBegin(@_);
}

sub artifactEnd {
  my $this = shift;
  $this->{children}->artifactEnd(@_);
}

sub modifyResource {
  my $this = shift;
  $this->{children}->modifyResource(@_);
}

sub modifyCommand {
  my $this = shift;
  return $this->{children}->modifyCommand(@_);
}

sub getVariable {
  my $this = shift;
  return $this->{children}->getVariable(@_);
}

return 1;
