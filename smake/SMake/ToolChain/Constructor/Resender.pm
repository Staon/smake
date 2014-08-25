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

# Generic resender constructor - this constructor appends some profiles and
# resends all commands to another constructors
package SMake::ToolChain::Constructor::Resender;

use SMake::ToolChain::Constructor::Constructor;

@ISA = qw(SMake::ToolChain::Constructor::Constructor);

use SMake::ToolChain::Resolver::Chain;

# Create new constructor object
#
# Usage: new(\@ctors, \@profiles)
#    ctors ..... list of constructors. Values can be a text - the constructor
#                is searched in the top constructor - or a reference to a
#                constructor.
#    profiles .. list of profiles
sub new {
  my ($class, $ctors, $profiles) = @_;
  my $this = bless(SMake::ToolChain::Constructor::Constructor->new(), $class);
  $this->{ctors} = $ctors;
  $this->{profiles} = $profiles;
  $this->{resolver} = SMake::ToolChain::Resolver::Chain->new();
  return $this;
}

# Append new resolve
sub appendResolver {
  my ($this, $resolver) = @_;
  $this->{resolver}->appendResolver($resolver);
}

sub iterateCtors {
  my ($this, $context, $func) = @_;
  
  foreach my $ctor (@{$this->{ctors}}) {
  	# -- search for the constructor
    if(!ref($ctor)) {
      $ctor = $context->getToolChain()->getConstructor()
          ->getConstructor($context, $ctor);
    }
    # -- execute the function
    &$func($ctor);
  }
}

# Construct artifact
#
# Usage: constructArtifact($context, $artifact)
#    context .... parser context
#    artifact ... the artifact object
sub constructArtifact {
  my ($this, $context, $artifact) = @_;

  # -- push the resolver
  $context->pushResolver($this->{resolver});
  # -- push the profiles
  $context->getProfiles()->appendProfile(@{$this->{profiles}});
  # -- resend to the constructors
  $this->iterateCtors($context, sub { $_[0]->constructArtifact($context, $artifact); });
}

# Resolve queue of resources in area of the artifact
#
# Usage: resolveResources($context, $artifact, \@list)
#    context ..... parser context
#    artifact .... the artifact object
#    list ........ list of resources
sub resolveResources {
  my ($this, $context, $artifact, $list) = @_;
  
  # -- resend to the constructors
  $this->iterateCtors(
      $context, sub { $_[0]->resolveResources($context, $artifact, $list); });
}

# Resolve list of dependencies
#
# Usage: resolveDependencies($context, $artifact, \@list)
#    context ..... parser context
#    artifact .... the artifact object
#    list ........ list of the dependencies
sub resolveDependencies {
  my ($this, $context, $artifact, $list) = @_;

  # -- resend to the constructors
  $this->iterateCtors(
      $context, sub { $_[0]->resolveDependencies($context, $artifact, $list); });
}

# Finish construction of an artifact
#
# Usage: finishArtifact($context, $artifact)
#    context ..... parser context
#    artifact .... the artifact object
sub finishArtifact {
  my ($this, $context, $artifact) = @_;

  # -- resend to the constructors
  $this->iterateCtors(
      $context, sub { $_[0]->finishArtifact($context, $artifact); });
}

return 1;
