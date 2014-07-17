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

# Generic dependency resolver
package SMake::ToolChain::Resolver::Dependency;

use SMake::ToolChain::Resolver::Resolver;

@ISA = qw(SMake::ToolChain::Resolver::Resolver);

use SMake::Utils::Abstract;

# Create new dependency resolver
#
# Usage: new($mask, \@mainres)
#    mask ..... mask of the dependency type
sub new {
  my ($class, $mask) = @_;

  my $this = bless(SMake::ToolChain::Resolver::Resolver->new(), $class);
  $this->{mask} = $mask;
  return $this;
}

sub doResolveResource {
  return 0;
}

sub doResolveDependency {
  my ($this, $context, $dependency) = @_;
  
  if($dependency->getDependencyType() =~ /$this->{mask}/) {
    $this->doJob($context, $dependency);
    return 1;
  }
  else {
    return 0;
  }
}

# Do the job with a matched dependency
#
# Usage: doJob($context, $dependency)
#    context ..... parser context
#    dependency .. the dependency
# 
sub doJob {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
