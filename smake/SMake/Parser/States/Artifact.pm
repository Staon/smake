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
  $this->{initialized} = 0;

  return $this;
}

sub initializeArtifact {
  my ($this, $parser, $context) = @_;

  if(!$this->{initialized}) {
    my $artifact = $context->getArtifact();
    
    # -- construct the artifact
    $context->getRepository()->getToolChain()->getConstructor()
        ->createMainResources($context, $artifact);

    # -- give a chance to the profiles
    $context->getProfiles()->artifactBegin(
        $context, $SMake::Parser::Parser::SUBSYSTEM, $artifact);
        
    $this->{initialized} = 1;
  }  
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

  $this->initializeArtifact($parser, $context);
  
  # -- create new source resources
  my $artifact = $context->getArtifact();
  my $reslist = [];
  my $wrong = $artifact->appendSourceResources(
      $context,
      $context->getResourcePrefix(),
      $srclist,
      $reslist); 
  if(defined($wrong)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::Parser::Parser::SUBSYSTEM,
          "complex or empty paths ('%s') are not allowed for directive 'Src'",
          $wrong);
  }
  
  # -- resolve appended resources
  $context->getToolChain()->getConstructor()->resolveResources(
      $context, $artifact, $reslist);
}

sub deps {
  my ($this, $parser, $context, $deptype, $deplist) = @_;

  $this->initializeArtifact($parser, $context);

  # -- append dependencies  
  my $object = $context->getArtifact();
  my $added = $object->appendDependencySpecs(
      $context, $SMake::Parser::Parser::SUBSYSTEM, $deptype, $deplist);

  # -- resolve appended dependencies
  $context->getToolChain()->getConstructor()->resolveDependencies(
      $context, $object, $added);
}

# Register new resolver object (valid only for current artifact)
#
# Usage: Resolver($resolver)
#    resolver ...... a resolver object
sub resolver {
  my ($this, $parser, $context, $resolver) = @_;
  $context->pushResolver($resolver);
}

# Register new source scanner object
#
# Usage: Scanner($scanner)
#    scanner ...... a scanner object
sub scanner {
  my ($this, $parser, $context, $scanner) = @_;
  $context->pushScanner($scanner);
}

# Register smake feature
#
# Usage: Feature($name, $type, \@onlist, \@offlist)
#    name ...... name of the feature
#    onlist .... list of the on-dependencies
#    offlist ... list of the off-dependencies
sub feature {
  my ($this, $parser, $context, $name, $type, $onlist, $offlist) = @_;

  $this->initializeArtifact($parser, $context);
  
  # -- get the feature object
  my $artifact = $context->getArtifact();
  my $feature = $artifact->getFeature($context, $name);
  if(!defined($feature)) {
    $feature = $artifact->createFeature($context, $name);
  }
  
  # -- on-dependencies
  foreach my $ondep (@$onlist) {
    $feature->appendOnDependency($context, $type, $ondep);
  }

  # -- off-dependencies
  foreach my $offdep (@$offlist) {
    $feature->appendOffDependency($context, $type, $offdep);
  }
}

sub endArtifact {
  my ($this, $parser, $context) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "EndArtifact()");

  my $artifact = $context->getArtifact();

  if($this->{initialized}) {
    # -- give a chance to the profiles
    $context->getProfiles()->artifactEnd(
        $context, $SMake::Parser::Parser::SUBSYSTEM, $artifact);
  
    # -- finish constructed artifact
    $context->getToolChain()->getConstructor()->finishArtifact(
        $context, $artifact);
  }
  
  # -- clear pushed resolvers and scanners
  $context->clearScanners();
  $context->clearResolvers();

  # -- remove the profile level
  $context->getProfiles()->popList();
  
  # -- change current context
  $context->popArtifact();
  $context->popResourcePrefix();

  # -- switch parser's state      
  $parser->switchState($this->{prjstate});
}

return 1;
