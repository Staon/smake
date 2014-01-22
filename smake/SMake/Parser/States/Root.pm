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

# Root parser state
package SMake::Parser::States::Root;

use SMake::Parser::States::State;

@ISA = qw(SMake::Parser::States::State);

use SMake::Parser::Parser;
use SMake::Parser::States::Ignore;
use SMake::Parser::States::Project;

# Create the state
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Parser::States::State->new(), $class);
  return $this;
}

sub startFile {
  # -- nothing is active yet, thus there is no job
}

sub finishFile {
  # -- there is no work here
}

sub subdirs {
  my ($this, $parser, $context, $subdirs) = @_;
  die "directive Subdirs must be used inside a project";
}

# Directive project
#
# Usage: project($name);
sub project {
  my ($this, $parser, $context, $name) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "Project('$name')");

  # -- get project object
  my $project = $context->getRepository()->getProject($name);
  if(!defined($project)) {
  	# -- new project, create the object
    my $prjdir = $context->getCurrentDir();
    $project = $context->getRepository()->createProject($name, $prjdir);
  
    # -- attach current description object with the project
    $project->attachDescription($context->getDescription());

    # -- set context
    $context -> pushProject($project);
  
    # -- switch parser's state
    $parser->switchState(
        SMake::Parser::States::Project->new($this));
  }
  else {
    # -- already parsed project, ignore rest of the project description
  	$context->getReporter()->report(
  	    3, "info", $SMake::Parser::Parser::SUBSYSTEM, "project '$name' has been already parsed.");
  	$parser->switchState(
  	    SMake::Parser::States::Ignore->new($this));
  }
}

return 1;
