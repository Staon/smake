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

use SBuild::DirectoryEngine;

#my $engine = SBuild::DirectoryEngine->newEngine("/workdir/os/sbuild/tests/astra3");
#my $engine = SBuild::DirectoryEngine->newEngine("../astra3");
#my $engine = SBuild::DirectoryEngine->newEngine;
my $engine = SBuild::DirectoryEngine->newEngine("/projekty/astra3/src/os/");

local $| = 1;

$engine->changeProjectDir("fbar2/fbar2server");

print "Prvni: " . $engine->getSourcePath . "\n";
print "Druha: " . $engine->getTargetPath . "\n";

print "Souce file: " . $engine->getSourceFile("pokus.cpp") . "\n";
print "Target file: " . $engine->getTargetFile("pokus.cpp") . "\n";

$engine->setTargetBaseMode();

print "Treti: " . $engine->getSourcePath . "\n";
print "Ctvrta: " . $engine->getTargetPath . "\n";

print "Souce file: " . $engine->getSourceFile("pokus.cpp") . "\n";
print "Target file: " . $engine->getTargetFile("pokus.cpp") . "\n";
