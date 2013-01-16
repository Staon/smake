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

#  The "task after" resource
package SMakeParser::TailResource;

use SMakeParser::PseudoResource;

@ISA = qw(SMakeParser::PseudoResource);

#  Ctor
#
#  Usage: newResource($id, $srcresid)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::PseudoResource->newResource("tail:" . $_[1]);
	$this->{srcresid} = $_[2];
	bless $this, $class;
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	# -- I depend on my source resource
	$map->appendDependency($this->getID, $this->{srcresid});
	
	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];

	# -- find the resource which I depend on.
	my $srcres = $map->getResource($this->{srcresid});
	my @tasklist = ();
	if(defined($srcres)) {
		my $reslist = $srcres->getTargetResources($profile);
		foreach my $res (@$reslist) {
			my $task = $this->processTailResource(
								$map, $assembler, $profile, $reporter, $res);
			return undef if(! defined($task));
			push @tasklist, $task;
		}
	}

	return \@tasklist;
}

#  Process a target resource (append the tail task to it)
#
#  Usage: processTailResource($map, $assembler, $profile, $reporter, $resource)
sub processTailResource {
	die "Pure virtual method: TailResource::processTailResource.";
} 

return 1;
