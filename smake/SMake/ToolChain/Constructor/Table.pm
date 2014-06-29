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

# Table constructor - it delegates to registered constructors according to
# artifact type
package SMake::ToolChain::Constructor::Table;

use SMake::ToolChain::Constructor::Constructor;

@ISA = qw(SMake::ToolChain::Constructor::Constructor);

use SMake::Utils::Utils;

# Create new table constructor
#
# Usage new([$type, $constructor]*)
#   type ......... type of artifacts
#   constructor .. constructor for the type
sub new {
  my $class = shift;
  my $this = bless(SMake::ToolChain::Constructor::Constructor->new(), $class);
  $this->{constructors} = {};
  $this->appendConstructors(@_);
  return $this;
}

# Append new cosntructors
#
# Usage appendConstructors([$type, $constructor]*)
#   type ......... type of artifacts
#   constructor .. constructor for the type
sub appendConstructors {
  my $this = shift;
  foreach my $rec (@_) {
    $this->{constructors}->{$rec->[0]} = $rec->[1];
  }
}

sub constructArtifact {
  my ($this, $context, $artifact) = @_;

  my $child = $this->{constructors}->{$artifact->getType()};
  if(!defined($child)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
        "type %s of artifact cannot be constructed",
        $artifact->getType());
  }
  return $child->constructArtifact($context, $artifact);
}

return 1;
