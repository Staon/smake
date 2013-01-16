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

#  Empty project designated for the LibRunner and WdbRunner.
package SBuild::ProjectListEmpty;

#  Ctor
sub newProjectList {
	my $class = shift;
	my $this = [];
	bless $this, $class;
}

#  Append a new project
#
#  Usage: appendProject($project)
sub appendProject {

}

#  Check if a project exists
#
#  Usage: doesExist($prjname)
#  Return: True when the project exist
sub doesExist {
	return 0;
}

#  Check if a stage of a project is empty
#
#  Usage: isStageEmpty($prjname, $stagename)
sub isStageEmpty {
	return 1;
}

#  Get a project
#
#  Usage: getProject($prjname)
#  Return: The project or undef
sub getProject {
	return undef;
}

#  Append a dependency node
#
#  Usage: addDepNode($prjid, $stageid)
sub addDepNode {

}

#  Append a project dependency
#
#  Usage: addDependency($srcprj, $srcstage, $tgprj, $tgstage)
sub addDependency {

}

#  Get topological ordered list of stages of projects to process
#
#  Usage: getProcessList(\@stages [, $filter])
#  Return: (result, list). When the result is true, list contains
#          topologicaly ordered project identifiers. When the result
#          is false, the list contains list of identifiers of cycled
#          projects.
sub getProcessList {
	return (0, []);
}

#  Init processing
#
#  Usage: initProcessing($profile, $reporter)
sub initProcessing {

}

#  Clean after a run
#
#  Usage: initProcessing($profile, $reporter)
sub cleanProcessing {

}

#  Process a list of projects
#
#  Usage: processList(\@list, $profile, $reporter, $force)
#  Return: True when the processing ends correctly.
sub processList {
	return 0;
}

sub printDependencies {

}

return 1;
 
