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

#  Associative list of projects
package SBuild::ProjectList;

use SBuild::TopOrder;

#  Ctor
sub newProjectList {
	my $class = shift;
	my $this = {
		dependencies => SBuild::TopOrder->newTopOrder
	};
	bless $this, $class;
}

#  Append a new project
#
#  Usage: appendProject($project)
sub appendProject {
	die "Invocation of a pure virtual method SBuild::ProjectList::appendProject()!";
}

#  Check if a project exists
#
#  Usage: doesExist($prjname)
#  Return: True when the project exist
sub doesExist {
	my $this = $_[0];
	my $prjname = $_[1];
	return defined($this->getProject($prjname)); 
}

#  Check if a stage of a project is empty
#
#  Usage: isStageEmpty($prjname, $stagename)
sub isStageEmpty {
	my $this = $_[0];
	my $prjname = $_[1];
	my $stagename = $_[2];

	my $project = $this->getProject($prjname);
	return $project->isStageEmpty($prjname) if(defined($project));
	return 1;
}

#  Get a project
#
#  Usage: getProject($prjname)
#  Return: The project or undef
sub getProject {
	die "Invocation of a pure virtual method SBuild::ProjectList::getProject()!";
}

#  Append a dependency node
#
#  Usage: addDepNode($prjid, $stageid)
sub addDepNode {
	my $this = $_[0];
	my $prjid = $_[1];
	my $stageid = $_[2];
	my $id = $prjid . ":" . $stageid;

	# append new node
	if(! $this->{dependencies}->doesExist($id)) {
		$this->{dependencies}->addNode($id, $id);
	}
}

#  Append a project dependency
#
#  Usage: addDependency($srcprj, $srcstage, $tgprj, $tgstage)
sub addDependency {
	my $this = $_[0];
	my $srcprj = $_[1];
	my $srcstage = $_[2];
	my $tgprj = $_[3];
	my $tgstage = $_[4];
	
	# Create full identifiers
	my $srcid = $srcprj . ":" . $srcstage;
	my $tgid = $tgprj . ":" . $tgstage;
	
	# Create nodes
	$this->addDepNode($srcprj, $srcstage);
	$this->addDepNode($tgprj, $tgstage);
	
	# Add dependency
	$this->{dependencies}->addDependency($srcid, $tgid);
}

#  Get topological ordered list of stages of projects to process
#
#  Usage: getProcessList(\@stages [, $filter])
#  Return: (result, list). When the result is true, list contains
#          topologicaly ordered project identifiers. When the result
#          is false, the list contains list of identifiers of cycled
#          projects.
sub getProcessList {
	my $this = $_[0];
	my $stages = $_[1];
	my $filter = $_[2];
	return $this->{dependencies}->computeDeps($stages, $filter);
}

#  Init processing
#
#  Usage: initProcessing($profile, $reporter)
sub initProcessing {
	die "Invocation of a pure virtual method SBuild::ProjectList::initProcessing()!";
}

#  Clean after a run
#
#  Usage: initProcessing($profile, $reporter)
sub cleanProcessing {
	die "Invocation of a pure virtual method SBuild::ProjectList::cleanProcessing()!";
}

#  Process a list of projects
#
#  Usage: processList(\@list, $profile, $reporter, $force)
#  Return: True when the processing ends correctly.
sub processList {
	my $this = $_[0];
	my $list = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	my $force = $_[4];

	my $retval = 1;
	
	foreach my $id (@$list) {
		# -- separate project name and stage name
		(my $prjname, my $stage) = split /[:]/, $id;
		my $project = $this->getProject($prjname);
		if(defined($project)) {
			# -- change working directory
			my $olddir = $profile->getDirEngine->getProjectDir;
			$profile->getDirEngine->changeProjectDir($project->getPath);
			my $info = $project->runProject($stage, $profile, $reporter);
			$profile->getDirEngine->setProjectDir($olddir);
			
			return 0 if(! $info and ! $force);
			$retval = $retval && $info;
		}
	}
	
	return $retval;
}

sub printDependencies {
	my $this = $_[0];
	$this->{dependencies}->printList;
}

return 1;
