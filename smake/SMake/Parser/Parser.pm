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

# Parser of SMakefiles and compositor of project model
package SMake::Parser::Parser;

use SMake::Parser::Chdir;
use SMake::Parser::States::Root;
use SMake::Utils::ArgChecker;
use SMake::Utils::Dirutils;
use SMake::Utils::Evaluate;
use SMake::Utils::Utils;

# -- reporter subsystem constant
$SUBSYSTEM = "parser";

##########################################################################
#                          Parser directives
##########################################################################

sub executeDirective {
  my $directive = shift;
  my ($package, $filename, $line) = caller(2);
  $parser_state->executeDirective($parser, $context, $directive, $line, @_);
}

# A directive without arguments
sub directive_ {
  executeDirective(@_);
}

# Directive with one scalar
sub directive_S {
  SMake::Utils::ArgChecker::checkScalar($_[0], $_[1], 1);
  executeDirective(@_);
}

sub directive_A {
  SMake::Utils::ArgChecker::checkArray($_[0], $_[1], 1);
  executeDirective(@_);
}

sub directive_B {
  my ($name, $arg1) = splice(@_, 0, 2);
  SMake::Utils::ArgChecker::checkScalarOrArray($name, $arg1, 1);
  executeDirective($name, SMake::Utils::Utils::getArrayRef($arg1));
}

sub directive_SSh {
  SMake::Utils::ArgChecker::checkScalar($_[0], $_[1], 1);
  SMake::Utils::ArgChecker::checkScalar($_[0], $_[2], 2);
  SMake::Utils::ArgChecker::checkOptHash($_[0], $_[3], 3);
  $_[3] = {} if(!defined($_[3]));
  executeDirective(@_);
}

##########################################################################
#                                Parser
##########################################################################

# Create new smake parser
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({
    dirstack => SMake::Parser::Chdir->new(),
    evals => {
      Project => \&directive_S,
      EndProject => \&directive_,
      Subdirs => \&directive_B,
      Artifact => \&directive_SSh,
      EndArtifact => \&directive_,
      Src => \&directive_A,
    },
  }, $class);
}

# Switch current parser state
sub switchState {
  my ($this, $state) = @_;
  $parser_state = $state;
}

# Parse a SMakefile
#
# Usage: parseFileCanonical($repository, $context, $path, $state)
#    context ...... parser context
#    path ......... path to the SMakefile (must be canonical)
#    state ........ initial parser state
sub parseFileCanonical {
  my ($this, $context_, $path, $state) = @_;
  
  # -- create the description object
  my $mark = $context_->getDecider()->hasChanged($path);
  my $descr = $context_->getRepository()->createDescription($path, $mark);

  # -- prepare context
  $context_->pushDescription($descr);
  $this->{dirstack}->pushDir($context_->getCurrentDir());
  
  # -- parse the file
  $context_->getReporter()->report(
      1, "info", $SUBSYSTEM, "parse description file '$path'");
  $state->startFile($this, $context_, $descr);
  {
    local $parser = $this;
    local $context = $context_;
    local $parser_state = $state;
    my $info = SMake::Utils::Evaluate::evaluateSpecFile($path, $this->{evals});
    if($info) {
      SMake::Utils::Utils::dieReport($context->getReporter(), $SUBSYSTEM, '%s', $info);
    }
  }
  $state->finishFile($this, $context_, $descr);
  $context_->getReporter()->reportf(
      3, "info", $SUBSYSTEM, "description file '%s' is parsed", $path);
  
  # -- clean context
  $this->{dirstack}->popDir();
  $context_->popDescription();
}

# Parse a SMakefile
#
# Usage: parseFile($repository, $context, $path, $state)
#    context ...... parser context
#    path ......... path to the SMakefile
#    state ........ initial parser state
sub parseFile {
  my ($this, $context_, $path, $state) = @_;
  $path = SMake::Utils::Dirutils::getCwd($path);
  $this->parseFileCanonical($context_, $path, $state);
}

# Parse a root SMakefile
#
# Usage: parseRoot($repository, $context, $path)
#    context ...... parser context
#    path ......... path to the SMakefile
sub parseRoot {
  my ($this, $context_, $path) = @_;
  $path = SMake::Utils::Dirutils::getCwd($path);
  my $root = SMake::Parser::States::Root->new();
  $this->parseFileCanonical($context_, $path, $root);
}

# Parse an SMakefile
#
# The method checks changes of the specification files and can cause refresh
# of the whole project.
#
# Usage: parser($repository, $context, $path)
#    repository ... developer's smake repository
#    context ...... parser context
#    path ......... path to the SMakefile
sub parse {
  my ($this, $repository, $context, $path) = @_;
  
  # -- check changes of the project specification
  my $canonical = SMake::Utils::Dirutils::getCwd($path);
  my $description = $repository->getDescription($canonical);
  
  
#  SMake::Utils::
}

return 1;
