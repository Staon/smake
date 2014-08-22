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

# Translator of an option value
package SMake::Executor::Translator::OptionValue;

use SMake::Executor::Translator::Value;

@ISA = qw(SMake::Executor::Translator::Value);

use SMake::Executor::Executor;
use SMake::Executor::Instruction::Shell;
use SMake::Utils::Utils;

# Create new option value
#
# Usage: new($address, $optional, $prefix, $suffix)
#    address .. address of the value
#    optional . a flag if the value is optional
sub new {
  my ($class, $address, $optional, $prefix, $suffix) = @_;
  
  my $this = bless(SMake::Executor::Translator::Value->new(
      $address, $optional), $class);
  $this->{prefix} = $prefix;
  $this->{suffix} = $suffix;
  return $this;
}

sub translateValue {
  my ($this, $context, $task, $command, $wd, $value) = @_;
  
  # -- search for a translation record
  if(defined($value)) {
    return [$this->{prefix} . $value->getValue() . $this->{suffix}];
  }
  else {
    return [];
  }
}

return 1;
