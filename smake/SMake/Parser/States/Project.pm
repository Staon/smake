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
  # -- nothing to do
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
      $context->getRepository(), $context->getCurrentDir(), $name, $type, $args);
  
  # -- change current context
  $context->pushArtifact($artifact);
  $context->pushResourcePrefix(SMake::Data::Path->new());

  # -- new profile level
  $context->getProfiles()->pushList();
  
  # -- construct artifact
  $context->getRepository()->getToolChain()->getConstructor()
      ->constructArtifact($context, $artifact);
  
  # -- switch parser state      
  my $state = SMake::Parser::States::Artifact->new($this);
  $parser->switchState($state);
}

sub endProject {
  my ($this, $parser, $context) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "EndProject()");

  my $project = $context->getProject();
  
  # -- give a chance to the profiles
  $context->getProfiles()->projectEnd(
      $context, $SMake::Parser::Parser::SUBSYSTEM, $project);

  # -- remove profile level
  $context->getProfiles()->popList();
  
  # -- update data of the ending project and remove it from the stack
  my $prj = $project->getObject();
  $context->popProject();
  $project->update($context);
  
  {
    local *::HANDLE;
    open(::HANDLE, ">&STDOUT");
    $prj->prettyPrint(0);
    close(::HANDLE);
  }
  
  # -- switch parser's state
  $parser->switchState($this->{root});
}

return 1;
