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

# Append external resources
package SMake::Profile::ExtResProfile;

use SMake::Profile::ResourceProfile;

@ISA = qw(SMake::Profile::ResourceProfile);

use SMake::Utils::Construct;

# Create new profile
#
# Usage: new($reslocation, $restype, $resmask, $task, $module, \@resources)
sub new {
  my ($class, $reslocation, $restype, $resmask, $task, $module, $resources) = @_;
  my $this = bless(SMake::Profile::ResourceProfile->new(
      $reslocation, $restype, $resmask, $task), $class);
  $this->{module} = $module;
  $this->{resources} = $resources;
  return $this;
}

sub doJob {
  my ($this, $context, $subsystem, $resource, $task) = @_;

  my $artifact = $resource->getArtifact();  
  foreach my $res (@{$this->{resources}}) {
    SMake::Utils::Construct::installExternalResource(
      $context,
      $artifact,
      $resource,
      $task,
      $this->{module},
      $res);
  }
}

return 1;
