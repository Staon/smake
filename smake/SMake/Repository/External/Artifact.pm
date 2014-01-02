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

# Implementation of the Artifact object for the External repository
package SMake::Repository::External::Artifact;

use SMake::Model::Artifact;

@ISA = qw(SMake::Model::Artifact);

# Create new artifact object
#
# Usage: new($repository, $project, $name, $type, \%args)
sub new {
  my ($class, $repository, $project, $name, $type, $args) = @_;
  my $this = bless(SMake::Model::Artifact->new(), $class);
  $this->{repository} = $repository;
  $this->{project} = $project;
  $this->{descriptions} = {};
  $this->{name} = $name;
  $this->{type} = $type;
  $this->{args} = $args;
  return $this;
}

sub attachDescription {
  my ($this, $description) = @_;
  $this->{descriptions}->{$description->getPath()} = $description;
}

return 1;
