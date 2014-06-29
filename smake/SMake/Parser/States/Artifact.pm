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

use SMake::Parser::Parser;
use SMake::Utils::Utils;

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
  
  # -- compute path relative to the artifact
  my $currprefix = $context->getResourcePrefix();
  my $prefix = $currprefix->joinPaths($context->getCurrentDir()->getBasepath());
  $context->pushResourcePrefix($prefix);
}

sub finishFile {
  my ($this, $parser, $context, $description) = @_;
  
  # -- clean resource prefix
  $context->popResourcePrefix();
}

sub src {
  my ($this, $parser, $context, $srclist) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "Src([@$srclist])");

  # -- create new source resources
  my $artifact = $context->getArtifact();
  my $wrong = $artifact->appendSourceResources(
      $context->getRepository(), $context->getResourcePrefix(), $srclist); 
  if(defined($wrong)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Parser::Parser::SUBSYSTEM,
          "complex or empty paths ('%s') are not allowed for directive 'Src'",
          $wrong);
  }
}

sub deps {
  my ($this, $parser, $context, $deptype, $deplist) = @_;
  
  my $artifact = $context->getArtifact();
  foreach my $dep (@$deplist) {
    $artifact->createDependency(
        $context, $deptype, $artifact->getProject()->getName(), $dep);
  }
}

sub endArtifact {
  my ($this, $parser, $context) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "EndArtifact()");
  
  # -- construct the artifact
  my $artifact = $context->getArtifact();
  $context->getRepository()->getToolChain()->getConstructor()
      ->constructArtifact($context, $artifact);
  
  # -- change current context
  $context->popArtifact();
  $context->popResourcePrefix();

  # -- switch parser's state      
  $parser->switchState($this->{prjstate});
}

return 1;
