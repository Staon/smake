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

#  Generator of a executable project
package SMakeGen::ExeGen;

use SMakeGen::ProjectGen;

@ISA = qw(SMakeGen::ProjectGen);

use SMakeGen::ProjectDirectiveGen;
use SMakeGen::EndProjectDirectiveGen;
use SMakeGen::ExecDirectiveGen;

#  Ctor
#
#  Usage: newProjectGen($prjname, $exename)
sub newProjectGen {
	my $class = $_[0];
	my $this = SMakeGen::ProjectGen->newProjectGen;
	$this->{prjname} = $_[1];
	$this->{exename} = $_[2];
	bless $this, $class;
}

#  Create list of directives
#
#  Usage: createDirectives
#  Return: list of directives
sub createDirectives {
	my $this = $_[0];
	
	my @list = ();
	push @list, SMakeGen::ProjectDirectiveGen->newDirectiveGen($this->{prjname});
	push @list, SMakeGen::ExecDirectiveGen->newDirectiveGen($this->{exename});
	push @list, SMakeGen::EndProjectDirectiveGen->newDirectiveGen;
	return \@list;
}

return 1;
