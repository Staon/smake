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

# Console reporter
package SMake::Reporter::TargetConsole;

use SMake::Reporter::Target;

@ISA = qw(SMake::Reporter::Target);

use Term::Cap;

# Create new console target
#
# Usage: new($decorated, $level, $types, $subsystem)
#    decorated .... if it's true, the level, type and subsystem are printed at each line
sub new {
  my ($class, $decorated, $level, $types, $subsystem) = @_;
  my $this = bless(SMake::Reporter::Target->new($level, $types, $subsystem), $class);
  $this->{decorated} = $decorated;

  # -- initialize the terminal
  if(-t STDOUT) {
    $this->{terminal} = Term::Cap->Tgetent({ TERM => undef, OSPEED => 9600 });
    $this->{colors} = [0, 4, 2, 6, 1, 5, 3, 7];
  }

  return $this;
}

# Set color of the terminal
#
# Usage: setColor($color)
#    color .... color code: 0 = black, red, green, yellow, blue, magenta, cyan, white
sub setColor {
  my ($this, $color) = @_;
  my $terminal = $this->{terminal};
  if(defined($terminal)) {
  	if(defined($terminal->{_setaf})) {
  	  print $terminal->Tgoto('setaf', $color, 0);
  	}
  	elsif(defined($terminal->{_setf})) {
  	  print $terminal->Tgoto('setf', $this->{colors}->[$color]);
  	}
  	else {
  	  $this->setBold($color != 7);
  	}
  }
}

# Set bold attribute
#
# Usage: setBold($flag)
#    flag ..... True activates the attribute, false clears it.
sub setBold {
  my ($this, $flag) = @_;
  my $terminal = $this->{terminal};
  if(defined($terminal)) {
    if(defined($terminal->{_md}) && defined($terminal->{_me})) {
      print $terminal->Tputs(($flag)?'md':'me', 0);
    }
  }
}

sub reportMessage {
  my ($this, $level, $type, $subsystem, $message) = @_;
  
  # -- compute console attributes
  my $color = 7; # -- white
  my $bold = 0;
  if($type eq "critical") {
    $color = 1; # -- red
  }
  elsif($type eq "error") {
    $color = 3; # -- yellow
  }
  elsif($type eq "warning") {
    $color = 2; # -- green
  }
  elsif($type eq "info") {
    if($subsystem =~ /[.]output$/) {
      $bold = 1;
    }
  }
  
  # -- set console attributes
  $this->setBold($bold);
  $this->setColor($color);

  {
    local $, = "";
    local $\ = "";
    print "[smake";
    if($this->{decorated}) {
      print ".", $subsystem,", level ", $level, ", ", $type;
    }
    print "]: ", $message, "\n";
  }  
  
  # -- clean up the attributes
  $this->setBold(0);
  $this->setColor(7);
}

return 1;
