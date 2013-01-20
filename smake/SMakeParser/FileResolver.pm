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

#  File resolver - it creates task and stages according
#                  to file extension.
package SMakeParser::FileResolver;

#  Ctor
sub newFileResolver {
	my $class = $_[0];
	my $this = {
		records => [],
		sysrecs => [],
		userrecs => []
	};
	bless $this, $class;
}

#  Append a new record
#
#  Usage: appendRecord($record)
sub appendRecord {
	my $this = $_[0];
	my $record = $_[1];
	my $records = $this->{records};
	$records->[@$records] = $record; 
}

#  Append a system record
#
#  Usage: appendSystemRecord($record)
sub appendSysRecord {
	my $this = $_[0];
	my $record = $_[1];
	my $records = $this->{sysrecs};
	push @$records, $record;
}

#  Append a new user record
#
#  Usage: appendUserRecord($record)
sub appendUserRecord {
	my $this = $_[0];
	my $record = $_[1];
	my $records = $this->{userrecs};
	$records->[@$records] = $record;
}

#  Clean all system and user records
sub cleanUserRecords {
	my $this = $_[0];
	$this->{sysrecs} = [];
	$this->{userrecs} = [];
}

#  Get a resolver
#
#  Usage: getResolver($resource)
#  Return: Resolver or undef
sub getResolver {
	my $this = $_[0];
	my $resource = $_[1];

	# -- try user records
	my $records = $this->{userrecs};
	foreach $record (@$records) {
		return $record if($record->isMine($resource));
	}

	# -- try system records
	$records = $this->{sysrecs};
	foreach $record (@$records) {
		return $record if($record->isMine($resource));
	}
		
	# -- try default records
	$records = $this->{records};
	foreach $record (@$records) {
		return $record if($record->isMine($resource));
	}

	return undef;
}

#  Extend the resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter, $resource)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];
	
	my $resolver = $this->getResolver($resource);
	if(defined($resolver)) {
		return $resolver->extendMap($map, $assembler, $profile, $reporter, $resource);
	}
	else {
		die "Unknown resolver to process resource " . $resource->getID . "!";
		$reporter->reportError("Unknown resolver for resource " . $resource->getID . "!");
		return 0;
	}
}

#  Resolve a resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter, $resource)
sub processResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];

	my $resolver = $this->getResolver($resource);
	if(defined($resolver)) {
		return $resolver->processResource($map, $assembler, $profile, $reporter, $resource);
	}
	else {
		$reporter->reportError("Unknown resolver for resource " . $resource->getID . "!");
		return 0;
	}
}

return 1;
