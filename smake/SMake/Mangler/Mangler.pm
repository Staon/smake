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

# Name mangler
#
# The name mangler creates resource names according to current context
package SMake::Mangler::Mangler;

use SMake::Data::Path;
use SMake::Utils::Evaluate;
use SMake::Utils::Utils;

##########################################################################
#    Basic functions
sub name {
  my ($mangler, $context, $resource) = @_;
  my $name = $resource->getBasename();
  $name =~ s/[.].*$//;
  return $name;
}

sub suffix {
  my ($mangler, $context, $resource) = @_;
  my $name = $resource->getBasename();
  $name =~ s/^[^.]*//;
  $name =~ s/^[.]//;
  return $name;
}

sub dir {
  my ($mangler, $context, $resource) = @_;
  return $resource->getDirpath()->asString();
}

##########################################################################
# Create new name mangler
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless({
    evals => {
      Result => sub {
        $mangler_context->{result} = $_[1];
      }
    }
  }, $class);
  $this->registerRecord("Dir", \&dir);
  $this->registerRecord("Name", \&name);
  $this->registerRecord("Suffix", \&suffix);
  return $this;
}

# Register a mangler record
#
# A record is actually a function which can be called from the mangle
# description. Arguments of the functions are: $mangler, $context, $resource
#
# Usage: registerRecord($name, \&function)
sub registerRecord {
  my ($this, $name, $function) = @_;
  $this->{evals}->{$name} = sub {
    return &$function(
        $this, $mangler_context->{context}, $mangler_context->{resource});
  };
}

# Mangle name of a resource
#
# Usage: mangleName($context, $description, $resource)
#    context ....... parser context
#    description ... mangle description
#    resource ...... mangled resource (an SMake::Data::Path)
# Returns: new mangled resource
sub mangleName {
  my ($this, $context, $description, $resource) = @_;
  local *mangler_context = \{context => $context, resource => $resource};
  $mangler_context->{mangler_context} = $mangler_context;
  my $retval = SMake::Utils::Evaluate::evaluateScript(
    'Result(' . $description . ");",
    $this->{evals});
  if(defined($retval)) {
    SMake::Utils::Utils::dieReport($context->getReporter(), "mangler", "%s", $retval);
  }
  return SMake::Data::Path->new($mangler_context->{result});
}

return 1;
