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

#  Compilation profile with only stored string
package SBuild::VarCompileProfile;

use SBuild::CompileProfile;
use SBuild::Option;

@ISA = qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile($name, $varname, $varvalue [, $prepend] )
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile->newCompileProfile($_[1]);
	$this->{varname} = $_[2];
	$this->{value} = $_[3];
	if($_[4]) { $this->{prepend} = 1 } else { $this->{prepend} = 0 }
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
#  Return: Updated value
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	
	if($this->{varname} eq $variable) {
		my $option = SBuild::Option->newOption($this->getName, $this->{value});
		if($this->{prepend}) {
			$optionlist->prependOption($option);
		}
		else {
			$optionlist->appendOption($option);
		}
	}
}

return 1;
