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

# A profile which appends dependency records into constructed artifact
# and it resolves them.
package SMake::Profile::DepProfile;

use SMake::Profile::ArtifactProfile;

@ISA = qw(SMake::Profile::ArtifactProfile);

use SMake::Utils::Abstract;

# Create new artifact profile
#
# Usage: new($typemask, $namemask, $deptype, \@deps)
#    typemask ...... a regular expression to match type of the artifact
#    namemask ...... a regular expression to match name of the artifact
#    deptype ....... dependency type
#    deps .......... list of dependency specifications (like the Deps directive)
sub new {
  my ($class, $typemask, $namemask, $deptype, $deps) = @_;
  my $this = bless(SMake::Profile::ArtifactProfile->new($typemask, $namemask), $class);
  $this->{deptype} = $deptype;
  $this->{deps} = $deps;
  return $this;
}

sub doBeginJob {
  # -- nothing to do
}

# Do job during artifact finishing
#
# Usage: doEndJob($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub doEndJob {
  my ($this, $context, $subsystem, $artifact) = @_;

  # -- append dependencies  
  my $added = $artifact->appendDependencySpecs(
      $context, $subsystem, $this->{deptype}, $this->{deps});

  # -- resolve appended dependencies
  $context->getToolChain()->getConstructor()->resolveDependencies(
      $context, $artifact, $added);
}

return 1;
