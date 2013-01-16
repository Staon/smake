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

# AKBC compilation task
package SMakeParser::AkbdTask;

use SBuild::CompileTask;

@ISA = qw(SBuild::CompileTask);

use SBuild::Profile;
use File::Spec;
use SMakeParser::ProfileUtils;

#  Ctor
#
#  Usage: newTask($name, $resource, \@target, \@source, \@deps, $icondir)
sub newTask {
	$class = $_[0];
	$this = SBuild::CompileTask->newTask($_[1], $_[2], $_[3], $_[4], $_[5]);
	$this->{icondir} = $_[6];
	bless $this, $class;
}

#  Get task command
#
#  Usage: getTaskCommand(profile, $reporter, \@targets, \@sources, $options)
#  Return: Command string
sub getTaskCommand {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $targets = $_[3];
	my $sources = $_[4];
	my $options = $_[5];

	# -- utility path
	my $path = SMakeParser::ProfileUtils::getFilePath($profile, "akbd_compile", "akbd_compile");

	# -- compose the command
	my $command = "$path";
	$command = $command . " -i " . $this->{icondir} if(defined($this->{icondir}));
	$command = $command . " -o " . $targets->[0]->getFullname($profile) . " " . $sources->[0]->getFullname($profile);
	
	return $command;
}

return 1;
