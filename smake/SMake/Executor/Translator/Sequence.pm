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

# Sequence translator - it executes several other translators
package SMake::Executor::Translator::Sequence;

use SMake::Executor::Translator::Translator;

@ISA = qw(SMake::Executor::Translator::Translator);

# Create new sequence translator
#
# Usage: new($translator*)
#    translator .... a translator object
sub new {
  my $class = shift;
  my $this = bless(SMake::Executor::Translator::Translator->new(), $class);
  $this->{records} = [];
  $this->appendRecords(@_);
  return $this;
}

# Append new records at the end of the sequencer
#
# Usage: appendRecords($translator*);
#    translator .... a translator object
sub appendRecords {
  my $this = shift;
  push @{$this->{records}}, @_;
}

sub translate {
  my ($this, $context, $command, $wd) = @_;
  
  my $retval = [];
  foreach my $record (@{$this->{records}}) {
    my $list = $record->translate($context, $command, $wd);
    push @$retval, @$list;
  }
  
  return $retval;
}

return 1;
