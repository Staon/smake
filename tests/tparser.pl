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

use SMakeParser::Parser;
use SMakeParser::FileParser;
use SMakeParser::StandardRunner;

use SBuild::Profile;
use SBuild::Reporter;
use SBuild::ProjectList;

use SBuild::DebugProfile;
use SBuild::VarCompileProfile;

# -- Prepare compilation environment
my $profile = SBuild::Profile->newProfile;
my $reporter = SBuild::Reporter->newReporter;

local $SMakeParser = SMakeParser::Parser->newParser(["lib"]);

my $runner = SMakeParser::StandardRunner->newStandardRunner($SMakeParser, $profile, $reporter);
my $prjlist = SBuild::ProjectList->newProjectList;
my $fileparser = SMakeParser::FileParser->newFileParser($SMakeParser, $runner, $prjlist);
$fileparser->parseFile("SMakefile", $profile, $reporter);

# -- Prepare compilation environment
my $proflist = SBuild::ProfileList->newProfileList;

# -- Activate debug info
#my $cprofile = SBuild::DebugProfile->newCompileProfile;
#$proflist->appendProfile($cprofile);
# -- Specify include path
$cprofile = SBuild::VarCompileProfile->newCompileProfile("", "CXXFLAGS", "-I. -I/projekty/astra3/src/include/ondrart");
$proflist->appendProfile($cprofile);
# -- Change library directory size
#my $libprofile = SBuild::VarCompileProfile->newCompileProfile("ondrart", "LIBFLAGS", "-p=128");
#$proflist->appendProfile($libprofile);

# -- Append the compilation profile list into the profile
$profile->getProfileStack()->pushList($proflist);


(my $result, my $processlist) = $prjlist->getProcessList("lib");
$prjlist->initProcessing;
$prjlist->processList($processlist, $profile, $reporter);
($result, $processlist) = $prjlist->getProcessList("bin");
$prjlist->initProcessing;
$prjlist->processList($processlist, $profile, $reporter);

($result, $processlist) = $prjlist->getProcessList("clean");
$prjlist->initProcessing;
$prjlist->processList($processlist, $profile, $reporter);
