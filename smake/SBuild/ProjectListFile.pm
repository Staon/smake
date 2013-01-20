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

#  Project list which stores projects in files
package SBuild::ProjectListFile;

use SBuild::ProjectList;

@ISA = qw(SBuild::ProjectList);

use SBuild::ProjectCache;

#  Ctor
sub newProjectList {
	my $class = shift;
	my $this = SBuild::ProjectList->newProjectList;
	$this->{prjlist} = {};
	$this->{cache} = SBuild::ProjectCache->newCache(128, "/tmp/smakecache/");
	bless $this, $class;
}

#  Append a new project
#
#  Usage: appendProject($project)
sub appendProject {
	my $this = $_[0];
	my $project = $_[1];
	my $name = $project->getName;
	$this->{prjlist}->{$name} = 1;
	$this->{cache}->putObject($name, $project);
}

#  Get a project
#
#  Usage: getProject($prjname)
#  Return: The project or undef
sub getProject {
	my $this = $_[0];
	my $prjname = $_[1];
	return $this->{cache}->getObject($prjname);
}

#  Init processing
#
#  Usage: initProcessing($profile, $reporter)
sub initProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $list = $this->{prjlist};
	my $cache = $this->{cache};

	my $retval = 1;	
	foreach my $project (keys(%$list)) {
		my $prj = $cache->getObject($project);
		$retval = $prj->initProcessing($profile, $reporter) && $retval;
	}
	
	return $retval;
}

#  Clean after a run
#
#  Usage: initProcessing($profile, $reporter)
sub cleanProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $list = $this->{prjlist};
	my $cache = $this->{cache};

	my $retval = 1;	
	foreach my $project (keys(%$list)) {
		my $prj = $cache->getObject($project);
		$retval = $prj->cleanProcessing($profile, $reporter) && $retval;
	}
	return $retval;
}

return 1;
