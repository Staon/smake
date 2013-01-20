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

#  Resource list
package SMakeParser::ResourceMap;

use SBuild::TopOrder;
use SBuild::SourceResource;
use SBuild::EmptyResource;

#  Ctor
sub newResourceMap {
	my $class = $_[0];
	my $this = {
		resources => {},
		stack => [],
		order => SBuild::TopOrder->newTopOrder
	};
	bless $this, $class;
}

#  Append a new resource
#
#  Usage: appendResource($resource)
#            When the resource exists the old resource is overwritten,
#            only the profile list is copied.
sub appendResource {
	my $this = $_[0];
	my $resource = $_[1];
	
	my $id = $resource->getID;
	my $old = $this->{resources}->{$id};
	if(defined($old)) {
		$resource->setProfileList($old->getProfileList) if(defined($old));
	}
	else {
		$this->{order}->addNode($id, $id) if(! $this->{order}->doesExist($id));
	}
	$this->{resources}->{$id} = $resource;
	push @{$this->{stack}}, $resource;
}

#  Append list of source resources
#
#  Usage: appendSourceResources(\@source_files)
sub appendSourceResources {
	my $this = $_[0];
	my $source_files = $_[1];
	
	foreach my $file (@$source_files) {
		$this->appendResource(SBuild::SourceResource->newResource($file));
	}
}

#  Get a resource
#
#  Usage: getResource($id)
#  Return: the resource or undef when the resource doesn't exist
sub getResource {
	my $this = $_[0];
	my $id = $_[1];
	return $this->{resources}->{$id};
}

#  Get resource (with lazy initialization of the resource)
#
#  Usage: getResourceOrCreateEmpty($id)
sub getResourceOrCreateEmpty {
	my $this = $_[0];
	my $id = $_[1];
	
	my $resource = $this->{resources}->{$id};
	if(! defined($resource)) {
		$resource = SBuild::EmptyResource->newResource($id);
		$this->{resources}->{$id} = $resource;
	}
	return $resource;
}

#  Append resource dependency
#
#  Usage: appendDependency($srcdep, $dstdep)
sub appendDependency {
	my $this = $_[0];
	my $srcdep = $_[1];
	my $dstdep = $_[2];
	
	my $order = $this->{order};
	$order->addNode($srcdep, $srcdep) if(! $order->doesExist($srcdep));
	$order->addNode($dstdep, $dstdep) if(! $order->doesExist($dstdep));
	$order->addDependency($srcdep, $dstdep); 
}

#  Append profile to a resource
#
#  Usage: appendProfile($resid, $profile)
#  Note: The resource must exist already!
sub appendProfile {
	my $this = $_[0];
	my $resid = $_[1];
	my $profile = $_[2];
	
	my $resource = $this->getResourceOrCreateEmpty($resid);
	$resource->appendProfile($profile);
}

#  Extend resource map from source resources
#
#  Usage: extendMap($resolver, $assembler, $profile, $reporter)
sub extendMap {
	my $this = $_[0];
	my $resolver = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	my $stack = $this->{stack};
	while($#$stack >= 0) {
		my $resource = pop @$stack;
#		print "Resource: " . $resource->getID . "\n";
		return 0 
			if(! $resolver->extendMap($this, $assembler, $profile, $reporter, $resource));
	}
	
	return 1;	
}

#  Create project structure according to the resource map
#
#  Usage: processMap($resolver, $assembler, $profile, $reporter)
sub processMap {
	my $this = $_[0];
	my $resolver = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	# -- compute topological order of resources
	my $order = $this->{order};
	my @rlist = reverse($order->computeOrder);
	
	# -- process the resources
	my $resources = $this->{resources};
	foreach my $rname (@rlist) {
		my $resource = $resources->{$rname};
		if(defined($resource)) {
			return 0
				if(!$resolver->processResource(
				                 $this, $assembler, $profile, $reporter, $resource));
		}
	}
	
	return 1;
}

return 1;
