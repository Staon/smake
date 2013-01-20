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

#  Memtest profile
#
#  This profile adds include paths and libraries to link
#  the memtest library
package SMakeParser::MemtestProfile;

use SBuild::CompileProfile;
use SBuild::Option;
use SBuild::Repository;
use SMakeParser::ProfileUtils;
use SBuild::TargetResource;

@ISA= qw(SBuild::CompileProfile);

#  Ctor
#
#  Usage: newCompileProfile($secretsrv, [$logfile])
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("memtest");
	$this->{secretservice} = $_[0];
	$this->{logfile} = $_[1];
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

	if($variable eq "CFLAGS" or $variable eq "CXXFLAGS") {
		my $path = SMakeParser::ProfileUtils::getFilePath($profile, "memtest.lib");
		my $arg = "";
		$arg = "='\"" . $this->{logfile} . "\"'" 
			if(defined($this->{logfile}));
		$optionlist->appendOption(SBuild::Option->newOption("", "-DMEMLEAKS_FIGHT${arg}"));
		$optionlist->appendOption(SBuild::Option->newOption("", "-I$path"));
	}
}

#  Modify current project
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];

	# -- add library
	$assembler->addLink(["memtest.lib", "ondrart_stdios.lib"]);
	$assembler->addForceLink("memtestservice.lib") if($this->{secretservice});

	# -- clean the log file
	if(defined($this->{logfile})) {
		$assembler->addClean(SBuild::TargetResource->newResource($this->{logfile}));
	}
}

return 1;
