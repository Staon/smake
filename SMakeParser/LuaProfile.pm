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

# LUA libraries
package SMakeParser::LuaProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;
use SMakeParser::ProjectAssembler;

#  Usage: newCompileProfile([\@modules])
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("lua");
	
	$this->{modules} = $_[0];
	if(! defined($this->{modules})) {
		$this->{modules} = ["mmlib", 
		                    "sendtxt", 
		                    "cfg", 
		                    "xml", 
		                    "mm", 
		                    "txtsrv", 
		                    "state", 
		                    "log", 
		                    "db"];
		$this->{deprecated} = 1;
	}
	else {
		$this->{deprecated} = 0;
	}
	
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	
}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];

	# -- basic LUA libraries
	my @liblist = ("lualib.lib", "alua.lib");
	
	# -- the modules
	foreach my $module (@{$this->{modules}}) {
		push @liblist, "alua_" . $module . ".lib";
	}
	
	# -- legacy library with deprecated objects
	if($this->{deprecated}) {
		push @liblist, "alua_deprecated.lib";
	}

	$assembler->addLink(\@liblist);
}

#  Get flag if a feature is active
#
#  Usage: isFeatureActive($feature_name, \$active_flag)
sub isFeatureActive {
	my ($this, $name, $flag) = @_;
	$$flag = 1 if($name eq "lua");
}

return 1;
