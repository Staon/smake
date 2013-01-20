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

# Compilation profile which causes rebuild of all compiled sources.
# It adds a dependency between compilation and clean phase.
package SMakeParser::RebuildProfile;

use SBuild::CompileProfile;
use SBuild::Option;

@ISA= qw(SBuild::CompileProfile);

#  Ctor
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("rebuild");
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
sub getOptions {

}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $project = $assembler->getProject;
	
	# -- add the dependency between compilation and
	#    clean stage to force rebuild.
	my $phase = $assembler->getPhase;
	if(defined($phase)) {
		$assembler->addStageDependency($phase->getFirstStage, $phase->getCleanStage);
	}
}

return 1;
