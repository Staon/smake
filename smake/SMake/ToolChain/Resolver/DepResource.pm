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

# Resolver of dependencies which appends the dependencies into a main resource
package SMake::ToolChain::Resolver::DepResource;

use SMake::ToolChain::Resolver::Dependency;

@ISA = qw(SMake::ToolChain::Resolver::Dependency);

use SMake::ToolChain::Constructor::Constructor;
use SMake::Utils::Searching;

# Create new dependency resolver
#
# Usage: new($mask, \@mainres)
#    mask ..... mask of the dependency type
#    mainres .. list of type of main resources
sub new {
  my ($class, $mask, $mainres) = @_;
  my $this = bless(SMake::ToolChain::Resolver::Dependency->new($mask), $class);
  if(ref($mainres) eq "ARRAY") {
    $this->{mainres} = $mainres;
  }
  else {
    $this->{mainres} = [$mainres];
  }
  
  return $this;
}

sub doJob {
  my ($this, $context, $dependency) = @_;
  
  # -- attach the dependency to the main resources
  my $artifact = $context->getArtifact();
  foreach my $mainr (@{$this->{mainres}}) {
    my $mainres = SMake::Utils::Searching::resolveMainResource($artifact, $mainr);
    if(!defined($mainres)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
          "dependency cannot be attached to main resource '%s'",
          $mainr);
    }
    my $task = $mainres->getTask();
    $task->appendDependency($context, $dependency, undef);
  }
}

return 1;
