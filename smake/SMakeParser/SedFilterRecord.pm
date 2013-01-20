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

#  Generic SED filter - generator of files
package SMakeParser::SedFilterRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::SourceResource;
use SBuild::TargetResource;

use SBuild::SedTask;

#  Ctor
#
#  When the argument $hdrgen is true, next argument is expected to be
#  a name of include directory. When it's false, next argument is a
#  stage where the generator is run. When the stage is empty, 'compile'
#  is used.
#
#  Usage: newRecord($mask, $outfile, $sedfile [, $stage])
sub newRecord {
	my $class = $_[0];
	# -- handle file mask
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	$this->{outfile} = $_[2];
	$this->{sedfile} = $_[3];
	$this->{stage} = $_[4];
	bless $this, $class;
}

sub getFilterResources {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $tgres = SBuild::TargetResource->newResource($this->{outfile});
	return $tgres;
}

#  Get a resource and create dependent resources (which are created from
#  this resource)
#
#  Usage: extendMapSpecial($map, $assembler, $profile, $reporter, $resource)
sub extendMapSpecial {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	# -- append all generated files
	my $tgres = $this->getFilterResources($resource);
	$map->appendResource($tgres);
	$map->appendDependency($tgres->getID, $resource->getID);

	return 1;
}

#  Process the file - create tasks
#
#  Usage: processResourceSpecial($map, $assembler, $profile, $reporter, $resource)
sub processResourceSpecial {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	my $sedres = SBuild::SourceResource->newResource($this->{sedfile});
	my $tgres = $this->getFilterResources($resource);
	my $hdrgen = $this->{hdrgen};
	
	my $task = SBuild::SedTask->newTask(
						$resource->getFilename, $resource,
						[$tgres], [$resource, $sedres], []);
	# -- If it's not a stage defined add the task into a compile stage of
	#    project's main phase.
	if(defined($this->{stage})) {
		$assembler->appendRawTask($this->{stage}, $task);
	}
	else {
		$assembler->appendTask("compile", $task);
	}
	# -- cleaning task
	$assembler->addClean($tgres);

	return $task;
}

return 1;
