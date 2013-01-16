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

#  Generic decider
#
#  The class decides if a set of files are out of time and
#  should be compiled.
package SBuild::Decider;

#  Ctor
sub newDecider {
	my $class = shift;
	my $this = {};
	bless $this, $class;
}

#  Pure virtual method!
#
#  This method decides if a set of target files are out of time
#  Usage: isOutOfTime(\@targets, \@sources)
#  Return: True when the targets are out of time
sub isOutOfTime {
	die "Pure virtual method Decider::isOutOfTime cannot be called!\n";
}

return 1;
