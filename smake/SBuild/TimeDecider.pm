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

#  File timestamp decider
package SBuild::TimeDecider;

use SBuild::Decider;
use File::stat;

@ISA = qw(SBuild::Decider);

#  Ctor
#
#  Create a timestamp decider
sub newDecider {
	my $class = shift;
	my $this = SBuild::Decider->newDecider;
	bless $this, $class;
}

#  This method decides if a set of target files are out of time.

#  Usage: isOutOfTime(\@targets, \@sources)
#  Return: True when the targets are out of time
sub isOutOfTime {
	my $this = $_[0];
	my $targets = $_[1];
	my $sources = $_[2];

	foreach $tg (@$targets) {
		# if the target file doesn't exist, everytime is
		# out of time.
		my $st = stat($tg) or return 1;
		my $mtime = $st->mtime;
		# Check source files
		foreach $src (@$sources) {
			my $src_st = stat($src) or return 1;
			return 1 if($mtime < $src_st->mtime);
		}
	}
	return 0;	
}

return 1;
