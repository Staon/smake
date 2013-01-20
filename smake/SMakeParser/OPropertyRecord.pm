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

# Processing of definition files of the properties
package SMakeParser::OPropertyRecord;

use SMakeParser::ResolverRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::TargetResource;
use SBuild::DepResource;

use SMakeParser::OPropertyTask;
use SMakeParser::OPropertyInstallTask;

#  Ctor
#
#  Usage: newRecord($mask, $targetmask, $dontinstall)
#
#  The targetmask can contain these characters:
#      v .... generate type and version records
#      b .... generate binder
#      m .... generate type marshallers
#      u .... generate type unmarshallers
sub newRecord {
	my $class = $_[0];
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	$this->{targetmask} = $_[2];
	$this->{dontinstall} = $_[3];
	bless $this, $class;
}

sub getTypeResources {
	my ($this, $resource) = @_;
	
	my $pure = $resource->getPurename;
	my @resources = ();
	push @resources, SBuild::TargetResource->newResource($pure . "_version.h");
	push @resources, SBuild::TargetResource->newResource($pure . "_version.cpp");
	
	return @resources;
}

sub getBinderResources {
	my ($this, $resource) = @_;
	
	my $pure = $resource->getPurename;
	my @resources = ();
	push @resources, SBuild::TargetResource->newResource($pure . "_binder.h");
	push @resources, SBuild::TargetResource->newResource($pure . "_binder.cpp");
	
	return @resources;
}

sub getMarshallerResources {
	my ($this, $resource) = @_;
	
	my $pure = $resource->getPurename;
	my @resources = ();
	push @resources, SBuild::TargetResource->newResource($pure . "_marshaller.h");
	push @resources, SBuild::TargetResource->newResource($pure . "_marshaller.cpp");
	
	return @resources;
}

sub getUnmarshallerResources {
	my ($this, $resource) = @_;
	
	my $pure = $resource->getPurename;
	my @resources = ();
	push @resources, SBuild::TargetResource->newResource($pure . "_unmarshaller.h");
	push @resources, SBuild::TargetResource->newResource($pure . "_unmarshaller.cpp");
	
	return @resources;
}

sub getResources {
	my ($this, $resource) = @_;
	
	my $pure = $resource->getPurename;
	my @resources = ();

	if($this->{targetmask} =~ /t/) {
		push @resources, $this->getTypeResources($resource);
	}	
	if($this->{targetmask} =~ /b/) {
		push @resources, $this->getBinderResources($resource);
	}
	if($this->{targetmask} =~ /m/) {
		push @resources, $this->getMarshallerResources($resource);
	}
	if($this->{targetmask} =~ /u/) {
		push @resources, $this->getUnmarshallerResources($resource);
	}
	
	return @resources;	
}

#  Get a resource and create dependent resources (which are created from
#  this resource)
#
#  Usage: extendMapSpecial($map, $assembler, $profile, $reporter, $resource)
sub extendMapSpecial {
	my ($this, $map, $assembler, $profile, $reporter, $resource) = @_;

	# -- create object resource
	my @resources = $this->getResources($resource);

	foreach my $tgres (@resources) {
		$map->appendResource($tgres);
		$map->appendDependency($tgres->getID, $resource->getID);
	}
	
	$assembler->addProjectDependency(
			$assembler->getProject->getName, 
            $assembler->getPhase->getFirstStage,
	        "opropertygen", "binpostlink");
	
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

	# -- compilation task
	my @resources = $this->getResources($resource);
	my $task = SMakeParser::OPropertyTask->newTask(
					$resource->getFilename,
					$resource,
					\@resources,
					[$resource],
					[],
					$this->{targetmask});
	$assembler->appendTask("precompile", $task);
	
	# -- resource cleaning
	foreach my $cleanres (@resources) {
		$assembler->addClean($cleanres);
	}
	
	# -- installation of the definition files
	if(! $this->{dontinstall}) {
		my $rawtask = $resource->getTargetResources->[0];
		my $installtask = SMakeParser::OPropertyInstallTask->newTask(
				"opropertyinst:" . $resource->getFilename,
				$resource,
				$resource->getFilename,
				$resource->getTargetResources->[0]);
		$assembler->appendTask("precompile", $installtask);
	}

	return $task;
}

return 1;
