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

# A profile which modifies artifact creation
package SMake::Profile::ArtifactProfile;

use SMake::Profile::Profile;

@ISA = qw(SMake::Profile::Profile);

use SMake::Utils::Abstract;

# Create new artifact profile
#
# Usage: new($typemask, $namemask)
#    typemask ...... a regular expression to match type of the artifact
#    namemask ...... a regular expression to match name of the artifact
sub new {
  my ($class, $typemask, $namemask) = @_;
  my $this = bless(SMake::Profile::Profile->new(), $class);
  $this->{typemask} = $typemask;
  $this->{namemask} = $namemask;
  return $this;
}

sub artifactBegin {
  my ($this, $context, $subsystem, $artifact) = @_;

  if($artifact->getType() =~ /$this->{typemask}/
     && $artifact->getName() =~ /$this->{namemask}/) {
    $this->doBeginJob($context, $subsystem, $artifact);
  }
}

sub artifactEnd {
  my ($this, $context, $subsystem, $artifact) = @_;

  if($artifact->getType() =~ /$this->{typemask}/
     && $artifact->getName() =~ /$this->{namemask}/) {
    $this->doEndJob($context, $subsystem, $artifact);
  }
}

# Do job during artifact beginning
#
# Usage: doBeginJob($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub doBeginJob {
  SMake::Utils::Abstract::dieAbstract();
}

# Do job during artifact finishing
#
# Usage: doEndJob($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub doEndJob {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
