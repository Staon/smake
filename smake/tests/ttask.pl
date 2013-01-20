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

use SBuild::Task;
use SBuild::Profile;
use SBuild::Reporter;

use SBuild::CCompileTask;
use SBuild::CXXCompileTask;
use SBuild::LinkTask;
use SBuild::LibTask;
use SBuild::CleanTask;

use SBuild::Stage;
use SBuild::Project;

use SBuild::VarCompileProfile;
use SBuild::DebugProfile;
use SBuild::PreprocProfile;

# -- Main project
my $project = SBuild::Project->newProject("MyTestProject");

# -- Prepare "compile" stage
my $stage = SBuild::Stage->newStage("compile");
$project->appendStage($stage);

# -- Compilation tasks of the compile stage
my $task = SBuild::CXXCompileTask->newTask("olog2.o", ["olog2.o"], ["olog2.cpp"], []);
$stage->appendTask($task);
$task = SBuild::CXXCompileTask->newTask("olog2_alog.o", ["olog2_alog.o"], ["olog2_alog.cpp"], []);
my $taskprof = SBuild::PreprocProfile->newCompileProfile("OLOG2_LOGSERV_LOGGER");
$task->appendProfile($taskprof);
$stage->appendTask($task);
$task = SBuild::CXXCompileTask->newTask("olog2_console.o", ["olog2_console.o"], ["olog2_console.cpp"], []);
$taskprof = SBuild::PreprocProfile->newCompileProfile("OLOG2_CONSOLE_LOGGER");
$task->appendProfile($taskprof);
$stage->appendTask($task);
$task = SBuild::CXXCompileTask->newTask("olog2_ios.o", ["olog2_ios.o"], ["olog2_ios.cpp"], []);
$taskprof = SBuild::PreprocProfile->newCompileProfile("OLOG2_FILE_LOGGER");
$task->appendProfile($taskprof);
$stage->appendTask($task);
$task = SBuild::CXXCompileTask->newTask("olog2_syslog.o", ["olog2_syslog.o"], ["olog2_syslog.cpp"], []);
$taskprof = SBuild::PreprocProfile->newCompileProfile("OLOG2_SYSLOG_LOGGER");
$task->appendProfile($taskprof);
$stage->appendTask($task);

# -- Prepare the "lib" stage
$stage = SBuild::Stage->newStage("lib");
$project->appendStage($stage);

# -- Compilation tasks of the lib stage
$task = SBuild::LibTask->newTask("olog2.lib", ["olog2.lib"], ["olog2.o", "olog2_alog.o", "olog2_console.o", "olog2_ios.o", "olog2_syslog.o"], []);
$stage->appendTask($task);

# -- Prepare the "clean" stage
$stage = SBuild::Stage->newStage("clean");
$project->appendStage($stage);

# -- Tasks of the stage "clean"
$task = SBuild::CleanTask->newTask("clean", ["olog2.lib", "olog2.lst", "olog2.o", "olog2_alog.o", "olog2_console.o", "olog2_ios.o", "olog2_syslog.o"]);
$stage->appendTask($task);

# -- Prepare compilation environment
my $profile = SBuild::Profile->newProfile;
my $reporter = SBuild::Reporter->newReporter;
my $proflist = SBuild::ProfileList->newProfileList;

# -- Activate debug info
my $cprofile = SBuild::DebugProfile->newCompileProfile;
$proflist->appendProfile($cprofile);
# -- Specify include path
$cprofile = SBuild::VarCompileProfile->newCompileProfile("", "CXXFLAGS", "-I/projekty/astra3/src/include/ondrart");
$proflist->appendProfile($cprofile);
# -- Change library directory size
my $libprofile = SBuild::VarCompileProfile->newCompileProfile("lib", "LIBFLAGS", "-p=64");
$proflist->appendProfile($libprofile);

# -- Append the compilation profile list into the profile
$profile->getProfileStack()->pushList($proflist);

# -- Run project's stages
$project->runProject("compile", $profile, $reporter);
$project->runProject("lib", $profile, $reporter);
$project->runProject("clean", $profile, $reporter);
