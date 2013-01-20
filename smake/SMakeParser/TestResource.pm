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

#  Test runner resource
package SMakeParser::TestResource;

use SMakeParser::BinaryResource;

@ISA = qw(SMakeParser::BinaryResource);

use SMakeParser::RunTestResource;
use SMakeParser::TestProfile;
use SMakeParser::TestResource;
use SMakeParser::CheckTask;

#  Ctor
#
#  Usage: newResource($runner, \%args)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::BinaryResource->newResource($_[1]);
	$this->setArguments($_[2]);
	bless $this, $class;
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMapBinary {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	# -- pseudo resource to generate the test runner
	my $runtest = SMakeParser::RunTestResource->newResource($this);
	$runtest->setProfileList($this->getProfileList);
	$map->appendResource($runtest);

	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResourceBinary {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	my $objfiles = $assembler->getObjectFiles;
	$this->{objfiles} = $objfiles;

	# -- test profile (to activate the "test" feature)
	my $test_profile = SMakeParser::TestProfile->newCompileProfile();
	$this->appendProfile($test_profile);
	
	# -- linking profile
	my $linker_composer = $assembler->getLinkerComposer;
	my $link_profile = SMakeParser::LibLinkProfile->newCompileProfile($linker_composer);
	$this->appendProfile($link_profile);

	# -- link test runner
	my $exeres = $this->getExeResource($profile);
	my $bintask = SBuild::BinTask->newTask(
						$this->getFilename,
						$linker_composer,
						$this,
						[$exeres], $objfiles, [], $this->getArguments);
	$assembler->appendTask("link", $bintask);
	# -- run the test runner
	my $checktask = SMakeParser::CheckTask->newTask(
						"check:" . $this->getFilename, $this, $exeres);
	$assembler->appendRawTask("check", $checktask);

	# -- clean the runner
	$assembler->addClean($exeres);
	
	# -- specify libraries which are needed by the OTest system
	$assembler->addLink(["configclient.lib", "datstr.lib", "kernel.lib", "licastra.lib",
	                     "olala.lib", "ondrart_assert.lib",
	                     "ondrart_bool.lib", "ondrart_dynreg.lib",
	                     "ondrart_getopt.lib", "ondrart_global.lib",
	                     "ondrart_help.lib", "astraios.lib", "ondrart_kernel.lib",
	                     "ondrart_term.lib", "ondrart_typo.lib", "otest.lib", 
	                     "oversion.lib", "textclient.lib", "utils.lib", "md5.lib",
			     "testutils.lib"]);
	$assembler->addSysLink(["ncurses3r.lib"]);

	# -- Make the project dependent on the otest utility
	$assembler->addProjectDependency($assembler->getProject->getName, 
                                     $assembler->getPhase->getFirstStage,
	                                 "otest", "binpostlink");

	return $bintask;
} 

return 1;
