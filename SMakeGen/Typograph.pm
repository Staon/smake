# Copyright (C) 2013 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is free software: you can redistribute it and/or modify
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

#  Typograph
package SMakeGen::Typograph;

#  Ctor
#
#  Usage: newTypograph($width);
sub newTypograph {
	my $class = $_[0];
	my $this = {
		width => $_[1],
		curr => 0,
		indent => 0,
		firstword => 1
	};
	bless $this, $class;
}

#  Set line indentation
#
#  Usage: setIndent($indent)
sub setIndent {
	my $this = $_[0];
	$this->{indent} = $_[1];
}

#  Get line indentation
sub getIndent {
	my $this = $_[0];
	return $this->{indent};
}

#  Break current line
sub breakLine {
	my $this = $_[0];
	
	print "\n";
	$this->{curr} = 0;
	$this->{firstword} = 1;
}

#  Print a text. Don't wrap lines.
#
#  Usage: forcePrintText($text[, $length]);
sub forcePrintText {
	my $this = $_[0];
	my $text = $_[1];
	my $len = $_[2];
	$len = length($text) if(! defined($len));
	my $indent = $this->{indent};
	
	# -- print indentation
	if($this->{firstword}) {
		my $i = 0;
		print ' ' while($i ++ < $indent);
		$this->{firstword} = 0;
		$this->{curr} += $indent;
	}	
	# -- print the text	
	print $text;
	$this->{curr} += $len;
}

#  Print a text. When the text overflows a line, it's wrapped.
#
#  Usage: printText($text);
sub printText {
	my $this = $_[0];
	my $text = $_[1];
	
	# -- break the line if it's needed
	my $length = length($text);
	$this->breakLine if(($length + $this->{curr}) >= $this->{width});
	# -- print text
	$this->forcePrintText($text, $length);
}

return 1;
