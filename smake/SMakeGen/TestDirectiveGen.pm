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

#  Generator of the Test directive
package SMakeGen::TestDirectiveGen;

use SMakeGen::FileDirectiveGen;

@ISA = qw(SMakeGen::FileDirectiveGen);

#  Ctor
#
#  Usage: newDirectiveGen($runner, $type)
sub newDirectiveGen {
	my $class = $_[0];
	my $this = SMakeGen::FileDirectiveGen->newDirectiveGen('[.](c|cpp|h)$');
	$this->{runner} = $_[1];
	$this->{type} = $_[2];
	bless $this, $class;
}

#  Generate the directive
#
#  Usage: generateDirective($typograph)
sub generateDirective {
	my $this = $_[0];
	my $typo = $_[1];

	my $currindent = $typo->getIndent;
	my $hdr = "Test(\"" . $this->{runner} . "\", ";
	$typo->printText($hdr);
	$typo->setIndent($currindent + length($hdr) + 1);
	$this->printListOfFiles($typo);
	$typo->forcePrintText(",");
	$typo->breakLine;
	$typo->setIndent($currindent + 5);
	$typo->printText("\"" . $this->{type} . "\");");
	$typo->setIndent($currindent);
	$typo->breakLine;
}

return 1;
