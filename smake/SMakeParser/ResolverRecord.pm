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

#  Generic resolver record
package SMakeParser::ResolverRecord;

use SBuild::Utils;

#  Ctor
#
#  Usage: newRecord($mask)
sub newRecord {
	my $class = $_[0];
	my $this = {
		patterns => SBuild::Utils::getArrayRef($_[1])
	};
	bless $this, $class;
}

#  Append a new resolver pattern
#
#  Usage: appendPattern(\@patterns)
sub addPattern {
	my $this = $_[0];
	my $patterns = SBuild::Utils::getArrayRef($_[1]);
	if(defined $patterns) {
		$this->{patterns} = [@{$this->{patterns}}, @$patterns];
	} 
}

#  Check if the file is mine
#
#  Usage: isMine($resource)
#  Return: True when it's mine
sub isMine {
	my $this = $_[0];
	my $resource = $_[1];
	my $patterns = $this->{patterns};
	my $name = $resource->getID;
	
	foreach my $pattern (@$patterns) {
		return 1 if($name =~ /$pattern/);
	}
	return 0;
}

#  Get a resource and create dependent resources (which are created from
#  this resource)
#
#  Usage: extendMap($map, $assembler, $profile, $reporter, $resource)
sub extendMap {
	my $this = shift;
	return $this->extendMapSpecial(@_);
}

#  Get a resource and create dependent resources (which are created from
#  this resource)
#
#  Usage: extendMapSpecial($map, $assembler, $profile, $reporter, $resource)
sub extendMapSpecial {
	die "Pure virtual method ResolverRecord::extendMapSpecial";
}

#  Process the file - create tasks
#
#  Usage: processResource($map, $assembler, $profile, $reporter, $resource)
sub processResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	my $resource = $_[5];
	
	# -- process the record
	my $task = $this->processResourceSpecial($map, $assembler, $profile, $reporter, $resource);
	return 0 if(! defined($task));

	# -- set resource task mark
	my $mark = $resource->getTaskMark;
	$task->setTaskMark($mark) if(defined($mark));
	
	return 1;
}

#  Process the file - create tasks
#
#  Usage: resolveResourceSpecial($map, $assembler, $profile, $reporter, $resource)
sub processResourceSpecial {
	die "Pure virtual method ResolverRecord::processFile cannot be invoked!\n";
}

return 1;
