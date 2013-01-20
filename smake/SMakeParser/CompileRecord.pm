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

#  Compilation resolver record
package SMakeParser::CompileRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SBuild::DepResource;
use SBuild::ScannerTask;
use SBuild::ComposeTask;

#  Ctor
#
#  Usage: newRecord($mask [, $prefix, $postfix])
sub newRecord {
	my $class = $_[0];
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	$this->{prefix} = $_[2];
	$this->{postfix} = $_[3];
	bless $this, $class;
}

sub getObjectResource {
	my $this = $_[0];
	my $resource = $_[1];

	my $objname = $resource->getPurename;
	$objname = $this->{prefix} . $objname if(defined($this->{prefix}));
	$objname = $objname . $this->{postfix} if(defined($this->{postfix}));
	return SBuild::TargetResource->newResource($objname . ".o");
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
	
	# -- create object resource
	my $objres = $this->getObjectResource($resource);
	$map->appendResource($objres);
	
	# -- specify resource dependencies
	$map->appendDependency($objres->getID, $resource->getID);
	
	return 1;
}

#  Process the file - create tasks
#
#  Usage: resolveResource($map, $assembler, $profile, $reporter, $resource)
sub processResourceSpecial {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	my $scanner = $this->getScanner;
	my $objres = $this->getObjectResource($resource);
	my $task;
	if(defined($scanner)) {
		# -- create scanner task
		my $depresource = SBuild::DepResource->newResource($resource->getPurename . ".dep");
		my $deptask = SBuild::ScannerTask->newTask(
							"scan:" . $resource->getFilename, $resource,
							$scanner, $resource, $depresource);
		# -- create compilation task
		$task = $this->getCompilationTask($resource, $objres, [$depresource]);
		# -- create compose task
		my $comptask = SBuild::ComposeTask->newTask(
							$resource->getFilename, undef,
							[$deptask, $task]);
		
		$assembler->appendTask("compile", $comptask);
		$assembler->addDepCleanDir($depresource->getDirectoryResource);
	}
	else {
		# -- only compilation task
		$task = $this->getCompilationTask($resource, $objres, []);
		$assembler->appendTask("compile", $task);
	}
	
	return $task;
}

#  Get name of a source scanner
sub getScanner {
	return undef;
}

#  Create compilation task
#
#  Usage: getCompilationTask($srcfile, $objectfile, \@deps)
sub getCompilationTask {
	die "Pure virtual method: CompileRecord::getCompilationTask";
}

return 1;
