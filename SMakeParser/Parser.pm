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

# Parser of the SMakefile files
package SMakeParser::Parser;

use SBuild::TopOrder;

#  Ctor
#
#  Usage: newParser(\@stages)
sub newParser {
	my $class = shift;
	my $this = {
		stages => $_[0],
#		prjdeps => SBuild::TopOrder->newTopOrder,
		files => [],
		idcounter => 0
#		projects => {}
	};
	bless $this, $class;
}

#  Get new number identifier
sub allocateID {
	my $this = shift;
	return ++ $this->{idcounter};
}

#  Create an identifier
#
#  Usage: getID($prefix, $id)
#  Return: It returns $id if it's not empty. When it's empty, an identifier
#          is returned. The identifier is composed from the $prefix and
#          the counter identifier.
sub getID {
	my $this = $_[0];
	my $prefix = $_[1];
	my $id = $_[2];
	
	if(! $id) {
		$id = $prefix . $this->allocateID;
	}
	
	return $id;
}

#  Push a file parser
#
#  Usage: pushParser($fileparser)
sub pushParser {
	my $this = $_[0];
	my $fileparser = $_[1];
	push @{$this->{files}}, $fileparser;
}

#  Pop a file parser
sub popParser {
	my $this = $_[0];
	pop @{$this->{files}};
}

#  Get top file parser
sub getTopParser {
	my $this = $_[0];
	return $this->{files}->[$#{$this->{files}}];
}

#  Append a project
#
#  Usage: appendProject($project)
#sub appendProject {
#	my $this = $_[0];
#	my $project = $_[1];
#	$this->{projects}->{$project->getName} = $project;
#}

#  Add a project dependency
#
#  Usage: addDependency($source, $target)
#sub addDependency {
#	my $this = $_[0];
#	my $source = $_[1];
#	my $target = $_[2];
#	
#	#$this->{prjdeps}->addDependency
#}

#  Add dependencies between the stages
#
#  Usage: addStageDependencies($prjlist, $depsrc, $deptg)
sub addStageDependencies {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $depsrc = $_[2];
	my $deptg = $_[3];
	
	if($depsrc) {
		foreach $stage (@{$this->{stages}}) {
			$prjlist->addDepNode($depsrc->getName, $stage);
			$prjlist->addDepNode($deptg->getName, $stage);
			$prjlist->addDependency(
			      $depsrc->getName, $stage,
			      $deptg->getName, $stage);
		}
	}
}

return 1;
