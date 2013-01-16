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

#  Usage pseudo-resource
package SMakeParser::UsageResource;

use SMakeParser::PseudoResource;

@ISA = qw(SMakeParser::PseudoResource);

use SMakeParser::UseTask;

#  Ctor
#
#  newResource($binres, $exeres, $usageres, $c_flag)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::PseudoResource->newResource("usage:" . $_[1]->getPurename);
	$this->{binres} = $_[1];
	$this->{exeres} = $_[2];
	$this->{usageres} = $_[3];
	$this->{c_flag} = $_[4];
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
	
	# -- these resources are dependent on the main resource
	$map->appendDependency($this->getID, $assembler->getMainResource);

	# -- task mark for the usage task
	$this->{mark} = $this->{binres}->setTaskMark("usage:" . $this->{binres}->getFilename);
	
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

	my $deptask = $assembler->getTask("link", $this->{binres}->getBinTaskName);
	my $task = SMakeParser::UseTask->newTask(
						$this->{binres},
						$this->{mark},
						$this->{exeres},
						$this->{usageres},
						$this->{c_flag});
	$assembler->appendTask("link", $task);

	if(! $this->{usageres}->isSourceResource) {
		$assembler->addClean($this->{usageres});
	}
	
	return $task;
} 

return 1;
