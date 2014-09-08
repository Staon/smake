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

use SMake::Model::Const;
use SMake::Parser::States::Root;
use SMake::Utils::ArgChecker;
use SMake::Utils::Chdir;
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

sub directive_SA {
  SMake::Utils::ArgChecker::checkScalar($_[0], $_[1], 1);
  SMake::Utils::ArgChecker::checkArray($_[0], $_[2], 2);
  executeDirective(@_);
}

sub directive_SSBB {
  my ($name, $arg1, $arg2, $arg3, $arg4) = splice(@_, 0, 5);
  SMake::Utils::ArgChecker::checkScalar($name, $arg1, 1);
  SMake::Utils::ArgChecker::checkScalar($name, $arg2, 2);
  SMake::Utils::ArgChecker::checkScalarOrArray($name, $arg3, 3);
  SMake::Utils::ArgChecker::checkScalarOrArray($name, $arg4, 4);
  executeDirective(
      $name,
      $arg1,
      $arg2,
      SMake::Utils::Utils::getArrayRef($arg3),
      SMake::Utils::Utils::getArrayRef($arg4));
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
    dirstack => SMake::Utils::Chdir->new(),
    evals => {
      Project => \&directive_S,
      EndProject => \&directive_,
      Subdirs => \&directive_B,
      Artifact => \&directive_SSh,
      EndArtifact => \&directive_,
      Src => \&directive_A,
      Deps => \&directive_SA,
      Profile => \&directive_S,
      Group => \&directive_,
      EndGroup => \&directive_,
      Resolver => \&directive_,
      Scanner => \&directive_,
      Feature => \&directive_SSBB,
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
#    path ......... path to the SMakefile (logical path in the meaning of the repos)
#    state ........ initial parser state
sub parseFile {
  my ($this, $context_, $path, $state) = @_;

  # -- prepare context
  my $currdir = $path->getDirpath();
  $context_->pushCurrentDir($currdir);
  $this->{dirstack}->pushDir(
      $context_->getRepository()->getPhysicalLocationString(
          $SMake::Model::Const::SOURCE_LOCATION, $currdir), 
      $context_->getReporter(),
      $SUBSYSTEM);

  # -- notify the state
  $state->startFile($this, $context_);
  
  # -- parse the file
  $context_->getReporter()->reportf(
      1, "info", $SUBSYSTEM, "parse description file '%s'", $path->printableString());
  {
    local $parser = $this;
    local $context = $context_;
    local $parser_state = $state;
    my $file = $context->getRepository()->getPhysicalLocationString(
        $SMake::Model::Const::SOURCE_LOCATION, $path);
    my $info = SMake::Utils::Evaluate::evaluateSpecFile($file, $this->{evals});
    if($info) {
      SMake::Utils::Utils::dieReport($context->getReporter(), $SUBSYSTEM, '%s', $info);
    }
  }
  $context_->getReporter()->reportf(
      3, "info", $SUBSYSTEM, "description file '%s' is parsed", $path->printableString());

  # -- notify the state
  $state->finishFile($this, $context_);
  
  # -- clean context
  $context_->popCurrentDir();
  $this->{dirstack}->popDir($context_->getReporter(), $SUBSYSTEM);
}

# Parse a root SMakefile
#
# Usage: parseRoot($context, $path)
#    context ...... parser context
#    path ......... path to the SMakefile
sub parseRoot {
  my ($this, $context_, $path) = @_;
  my $root = SMake::Parser::States::Root->new();
  $this->parseFile($context_, $path, $root);
}

# Parse an SMakefile
#
# The method checks changes of the specification files and can cause refresh
# of the whole project. If the description file is not changed, the method
# immediately ends.
#
# Usage: parse($repository, $context, $path)
#    context ...... parser context
#    path ......... logical path to the description file
sub parse {
  my ($this, $context, $path) = @_;

  # -- the file is not known, parse it
  $this->parseRoot($context, $path);
}

return 1;
