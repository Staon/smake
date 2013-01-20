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

#  Empty resolver record - it's used to handle headers
package SMakeParser::EmptyRecord;

@ISA = qw(SMakeParser::ResolverRecord);

use SBuild::CheckFileTask;

#  Ctor
#
#  Usage: newRecord($mask [, $install])
sub newRecord {
	my $class = $_[0];
	my $this = SMakeParser::ResolverRecord->newRecord($_[1]);
	$this->{install} = $_[2];
	bless $this, $class;
}

#  Get a resource and create dependent resources (which are created from
#  this resource)
#
#  Usage: extendMapSpecial($map, $assembler, $profile, $reporter, $resource)
sub extendMapSpecial {
#	my $this = $_[0];
#	my $map = $_[1];
#	my $assembler = $_[2];
#	my $profile = $_[3];
#	my $reporter = $_[4];
#	my $resource = $_[5];

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

	# -- create the task
	my $task = SBuild::CheckFileTask->newTask($resource->getFilename, $resource, $resource);
	# -- append task to the runner
	$assembler->appendTask("compile", $task);

	# -- installation task
	if(defined($this->{install})) {
		my $insttask = SBuild::InstallTask->newTask(
							"install:" . $resource->getFilename,
							$resource,
							$this->{install},
							$resource);
		$assembler->appendInstallTask($insttask);
	}

	return $task;
}

return 1;
