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

#  Preprocesor variable profile
package SBuild::PreprocProfile;

use SBuild::CompileProfile;
use SBuild::Option;

@ISA = qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile($varname, $varvalue, $tokenflag)
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile->newCompileProfile("preproc");
	$this->{varname} = $_[1];
	$this->{varvalue} = $_[2];
	$this->{tokenflag} = $_[3];
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
#  Return: Updated value
sub getOptions {
	my $this = $_[0];
	my $var = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	
	if(($var eq "CPPFLAGS") or ($var eq "CXXCPPFLAGS")) {
		# -- macro name
		my $value = "-D" . $this->{varname};
		# -- macro value. User can specify three types of values:
		#       1) a number (a text which contains only digits). The value is passed
		#          to the compiler as a numeric literal.
		#       2) A string which starts and ends with double quotes. Then the
		#          value is passed to the compiler as it is (so it is a string literal)
		#       3) In all other cases the value is quoted and passed to the compiler
		#          as a string literal.
		my $varvalue = $this->{varvalue};
		if(defined($varvalue) && $varvalue !~ /^\d+$/ ) {
			# -- some kind of a string
			if($varvalue !~ /^".*"$/ && ! $this->{tokenflag}) {
				# -- quote the string
				$varvalue = '"' . $varvalue . '"';
			}
			# -- quote the whole string to avoid handling of nested quotes by the shell
			$varvalue = "'" . $varvalue . "'";
		}
		
		$value = $value . "=" . $varvalue if(defined($this->{varvalue}));
		$optionlist->appendOption(SBuild::Option->newOption("", $value));
	}
}

return 1;
