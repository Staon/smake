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

# Parser state - parsing of an artifact
package SMake::Parser::States::Artifact;

use SMake::Parser::States::State;

@ISA = qw(SMake::Parser::States::State);

use File::Basename;
use File::Spec;
use SMake::Parser::Parser;

# Create new state
#
# Usage: new($prjstate)
sub new {
  my ($class, $prjstate) = @_;
  my $this = bless(SMake::Parser::States::State->new(), $class);
  $this->{prjstate} = $prjstate;

  return $this;
}

sub startFile {
  my ($this, $parser, $context, $description) = @_;
  $context->getProject()->attachDescription($description);
  $context->getArtifact()->attachDescription($description);
  
  # -- compute path relative to the artifact
  my $currprefix = $context->topResourcePrefix();
  my $dir = File::Basename->basename(File::Basename->dirname($description->getPath()));
  $context->pushResourcePrefix(File::Spec->catfile($currprefix, $dir));
}

sub finishFile {
  # -- nothing to do
}

sub src {
  my ($this, $parser, $context, $srclist) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "Src([@$srclist])");

}

sub endArtifact {
  my ($this, $parser, $context) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "EndArtifact()");
  
  # -- change current context
  $context->popArtifact();
  $context->popResourcePrefix();

  # -- switch parser's state      
  $parser->switchState($this->{prjstate});
}

return 1;
