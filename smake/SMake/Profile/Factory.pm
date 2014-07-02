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

# Factory of compilation profiles
package SMake::Profile::Factory;

# Create new factory
sub new {
  my ($class) = @_;
  return bless({ records => {} }, $class);
}

# Register new factory record
#
# Usage: registerRecord($name, $module, ...)
#    name ...... name of the profile
#    module .... name of the profile's module
#    ... and other arguments to create the profile
sub registerRecord {
  my ($this, $name, $module, @args) = @_;
  $this->{records}->{$name} = [$module, \@args];
}

# Create specified profile
#
# Usage: createProfile($name, ...)
#    name ...... name of the profile
#    ... and other arguments (chained after arguments specified in the ctor)
# Return:
#    The profile or undef value, if the profile is not known
sub createProfile {
  my ($this, $name, @args) = @_;
  my $record = $this->{records}->{$name};
  if(defined($record)) {
  	return $record->[0]->new($name, @{$record->[1]}, @args);
  }
  else {
  	return undef;
  }
}

return 1;
