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

# Generic parser state
package SMake::Parser::States::State;

use File::Spec;
use SMake::Parser::Parser;
use SMake::Utils::Abstract;
use SMake::Utils::Dirutils;

# Create new parser state
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Start parsing of a description file
#
# Usage: startFile($parser, $context, $description)
sub startFile {
  SMake::Utils::Abstract::dieAbstract();
}

# Finish parsing of a description file
#
# Usage: finishFile($parser, $context, $description)
sub finishFile {
  SMake::Utils::Abstract::dieAbstract();
}

# Execute directive
#
# Usage: executeDirective($stackdepth, $parser, $context, $directive, ...)
sub executeDirective {
  my ($this, $parser, $context, $directive, $line) = splice(@_, 0, 5);
  my $method = lcfirst($directive);
  if($this->can($method)) {
    $this->$method($parser, $context, @_);
  }
  else {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Parser::Parser::SUBSYSTEM,
        "Directive '%s' (at line %d) is used in a wrong context",
        $directive,
        $line);
  }
}

sub subdirs {
  my ($this, $parser, $context, $subdirs) = @_;
  $context->getReporter()->report(
      5, "debug", $SMake::Parser::Parser::SUBSYSTEM, "Subdirs(@$subdirs)");

  my $basedir = $context->getCurrentDir();
  for my $dir (@$subdirs) {
    # -- construct description path
    my $path = File::Spec->catfile(($basedir, $dir), "SMakefile");
    $path = SMake::Utils::Dirutils::getCwd($path);
    
    # -- parse the description file
    $parser->parseFileCanonical($context, $path, $this);
  }
}

return 1;
