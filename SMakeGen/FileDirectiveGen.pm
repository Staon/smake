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

#  A directive generator which scans source files
package SMakeGen::FileDirectiveGen;

use SMakeGen::DirectiveGen;

@ISA = qw(SMakeGen::DirectiveGen);

#  Ctor
#
#  Usage: newDirectiveGen($filemask)
sub newDirectiveGen {
	my $class = $_[0];
	my $this = SMakeGen::DirectiveGen->newDirectiveGen;
	$this->{filemask} = $_[1];
	$this->{filelist} = [];
	bless $this, $class;
}

#  Print list of files
#
#  Usage: printList($typograph, \@list)
sub printList {
	my $this = $_[0];
	my $typo = $_[1];
	my $list = $_[2];

	$typo->printText("[");
	my $first = 1;		
	foreach my $item (@$list) {
		if(! $first) {
			$typo->forcePrintText(", ");
		}
		$typo->printText("\"$item\"");
		$first = 0;
	}
	$typo->printText("]");
}

#  Get list of files
sub findListOfFiles {
	my $this = $_[0];
	my $filemask = $this->{filemask};

	opendir(DIR, '.') or die "Can't open current directory: $!";
	my @files = grep { /$filemask/ } readdir(DIR);
	closedir DIR;
	$this->{filelist} = \@files;
}

#  Get and print list of files
#
#  Usage: printListOfFiles($typograph)
sub printListOfFiles {
	my $this = $_[0];
	my $typo = $_[1];
	$this->findListOfFiles;
	$this->printList($typo, $this->{filelist});
}

return 1;
