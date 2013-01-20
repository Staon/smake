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

#  Generator of the OProperties
package SMakeParser::OPropertyTask;

use SBuild::CompileTask;

@ISA = qw(SBuild::CompileTask);

use SMakeParser::ProfileUtils;

#  Ctor
#
#  Usage: newTask($name, $resource, \@targets, \@sources, \@deps, targetmask)
sub newTask {
	my $class = shift;
	my $this = SBuild::CompileTask->newTask($_[0], $_[1], $_[2], $_[3], $_[4]);
	$this->{targetmask} = $_[5];
	bless $this, $class;
}

#  Get taks command
#
#  Usage: getTaskCommand($profile, $reporter, \@targets, \@sources, $options)
#  Return: Command string
sub getTaskCommand {
	my ($this, $profile, $reporter, $targets, $sources, $options) = @_;

	# -- get path of the makeversion utility
	my $genutil = SMakeParser::ProfileUtils::getFilePath($profile, "opropertygen", "opropertygen");

	$genutil .= " -" . $this->{targetmask};
	$genutil .= " -P .";
	my @dirlist = $profile->getRepository()->getModuleDirectories("oproperties");
	foreach my $dir (@dirlist) {
		$genutil .= " -P $dir";
	}
	$genutil .= " " . $sources->[0]->getFullname($profile);

	return $genutil;	
}

return 1;
