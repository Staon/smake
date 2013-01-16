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

#  Several utility function for implementing of compilation profiles
package SMakeParser::ProfileUtils;

use File::Spec;

#  Make current project dependent on a stage of another project
#  When both project are equal, the function does nothing
#
#  Usage: addProfileDependency($assembler, $srcstage, $tgprj, $tgstage)
sub addProfileDependency {
	my $assembler = $_[0];
	my $srcstage = $_[1];
	my $tgprj = $_[2];
	my $tgstage = $_[3];
	
	# Don't do dependency to self project
	if($tgprj eq $assembler->getProject->getName) { return }
	
	# Make the dependency
	$assembler->addProjectDependency(
					$assembler->getProject->getName, $srcstage,
					$tgprj, $tgstage);
}

#  Usage: addProfilePhaseDependency($assembler, $srcphstage, $tgprj, $tgstage)
sub addProfilePhaseDependency {
	my $assembler = $_[0];
	my $srcphstage = $_[1];
	my $tgprj = $_[2];
	my $tgstage = $_[3];
	
	# Find current phase. When there is no phase, don't do anything
	my $phase = $assembler->getPhase;
	if(defined($phase)) {
		addProfileDependency($assembler, $phase->getRawStage($srcphstage), $tgprj, $tgstage);
	}
}

#  Usage: add LibraryDependency($assembler, $libprj)
sub addLibraryDependency {
	my $assembler = $_[0];
	my $libprj = $_[1];
	
	# -- don't do library creation dependent on a library!
	my $phase = $assembler->getPhase;
	if(defined($phase) && ($phase->getName ne "lib")) {
		addProfileDependency($assembler, $phase->getRawStage("link"), $libprj, "libinst");
	}
}

#  Usage: getFilePath($profile, $prjname [, $file])
sub getFilePath {
	my $profile = $_[0];
	my $prjname = $_[1];
	my $file = $_[2];
	
	my $path = $profile->getRepository->getProjectPath($prjname);
	if(! defined($path)) {
		die "Project $prjname isn't registered in the repository!\n";
	}
	$path = File::Spec->catfile($path, $file) if(defined($file));
	return $path;	
}

return 1;
