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

# Generic value translator
package SMake::Executor::Translator::Select;

use SMake::Executor::Translator::Value;

@ISA = qw(SMake::Executor::Translator::Value);

use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new select translator
#
# Usage: new($address, $dflt, [$value, $cmdstr]*)
#    address .. address of the value
#    dflt ..... default command string (can be nil, default value is not allowed)
#    value .... a regular expression which describes the value of the logical node
#    cmdstr ... string which is added into the shell command
sub new {
  my ($class, $dflt) = splice(@_, 0, 2);
  my $this = bless(SMake::Executor::Translator::Value->new($address), $class);
  $this->{dflt} = $dflt;
  $this->{records} = [@_];
  return $this;
}

sub translateValue {
  my ($this, $context, $command, $wd, $value) = @_;
  
  # -- search for a translation record
  my $strval = $value->getValue();
  foreach my $record (@{$this->{records}}) {
    if($strval =~ /$record->[0]/) {
      return [$record->[1]];
    }
  }
  
  # -- no record found, use the default value
  if(defined($this->{dflt})) {
    return [$this->{dflt}];
  }
  else {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $SMake::Executor::Executor::SUBSYSTEM,
        "there is no registered command string for option %s with value %s",
        $value->getName(),
        $strval);
  }
}

return 1;
