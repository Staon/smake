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
use SMake::Update::Project;

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

  # -- create the update object
  my $project = SMake::Update::Project->new(
      $context, $name, $context->getCurrentDir());
  $context->pushProject($project);
  
  # -- prepare new profile level
  $context->getProfiles()->pushList();
      
  # -- switch parser's state
  $parser->switchState(
      SMake::Parser::States::Project->new($this));
}

return 1;
