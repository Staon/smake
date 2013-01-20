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

use SBuild::ProjectCache;

my $cache = SBuild::ProjectCache->newCache(4, "/tmp/smakecache/");

my @vals = ("Project1", "Project2", "Project3", "Project4", "Project5");
my $project;

# -- no stored value
for(my $i = 0; $i < 5; ++ $i) {
	$project = $cache->getObject($vals[$i]);
	! defined($project) or die;
}

# -- only one stored value
$cache->putObject($vals[0], $vals[0]);
$project = $cache->getObject($vals[0]);
$project eq $vals[0] or die;
for(my $i = 1; $i < 5; ++ $i) {
	$project = $cache->getObject($vals[$i]);
	! defined($project) or die;
}

# -- two values
$cache->putObject($vals[1], $vals[1]);
$project = $cache->getObject($vals[0]);
$project eq $vals[0] or die;
$project = $cache->getObject($vals[1]);
$project eq $vals[1] or die;
for(my $i = 2; $i < 5; ++ $i) {
	$project = $cache->getObject($vals[$i]);
	! defined($project) or die;
}

# -- all values
$cache->putObject($vals[2], $vals[2]);
$cache->putObject($vals[3], $vals[3]);
$cache->putObject($vals[4], $vals[4]);
for(my $i = 0; $i < 5; ++ $i) {
	$project = $cache->getObject($vals[$i]);
	print "$project\n";
	$project eq $vals[$i] or die;
}
