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

# Parser state - parsing of a project
package SMake::Parser::States::Project;

use SMake::Parser::States::State;

@ISA = qw(SMake::Parser::States::State);

use SMake::Data::Path;
use SMake::Parser::Parser;
use SMake::Parser::States::Artifact;

# Create new state
#
# Usage: new($rootstate)
sub new {
  my ($class, $root) = @_;
  my $this = bless(SMake::Parser::States::State->new(), $class);
  $this->{root} = $root;
  
  return $this;
}

sub startFile {
  my ($this, $parser, $context, $description) = @_;
  $context->getProject()->attachDescription($description);
}

sub finishFile {
  # -- nothing to do
}

sub artifact {
  my ($this, $parser, $context, $name, $type, $args) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "Artifact($name, $type);");

  # -- create new artifact
  my $artifact = $context->getProject()->createArtifact(
      $context->getCurrentDir(), $name, $type, $args);
  $artifact->attachDescription($context->getDescription());
  
  # -- change current context
  $context->pushArtifact($artifact);
  $context->pushResourcePrefix(SMake::Data::Path->new());
  
  # -- switch parser state      
  my $state = SMake::Parser::States::Artifact->new($this);
  $parser->switchState($state);
}

sub endProject {
  my ($this, $parser, $context) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "EndProject()");
  
  # -- commit project changes
  $context->getRepository()->acceptProject($context->getProject());
  
  # -- change the context
  $context->popProject();
  
  # -- switch parser's state
  $parser->switchState($this->{root});
}

return 1;
