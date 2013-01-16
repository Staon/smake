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

#  Factory of project generators
package SMakeGen::GenFactory;

use SMakeGen::LibGen;
use SMakeGen::ExeGen;
use SMakeGen::TestGen;
use SMakeGen::RootGen;

#  Ctor
sub newGenFactory {
	my $class = $_[0];
	my $this = {
		factory => {
			'lib' => SMakeGen::LibGen,
			'exec' => SMakeGen::ExeGen,
			'test' => SMakeGen::TestGen,
			'root' => SMakeGen::RootGen
		}
	};
	bless $this, $class;
}

#  Create project generator
#
#  Usage: getGenerator($genname, generic arguments...)
#  Return: the generator
sub getGenerator {
	my $this = shift;
	my $genname = shift;
	my $gen = $this->{factory}->{$genname};
	return $gen->newProjectGen(@_) if(defined($gen));
	return undef;
}

return 1;
