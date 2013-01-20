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

#  Generator of a SMakefile directive
package SMakeGen::DirectiveGen;

#  Ctor
#
#  Usage: newDirectiveGen($filemask)
sub newDirectiveGen {
	my $class = $_[0];
	my $this = {};
	bless $this, $class;
}

#  Generate the directive
#
#  Usage: generateDirective($typograph)
sub generateDirective {
	die "It's not possible to invoke pure virtual method DirectiveGen::generateDirective!";
}

return 1;
