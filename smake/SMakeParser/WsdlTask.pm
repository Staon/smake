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

#  Standard gSoap task
package SMakeParser::WsdlTask;

use SBuild::CompileTask;
use SBuild::Profile;
use SMakeParser::ProfileUtils;

@ISA = qw(SBuild::CompileTask);

# Ctor
#   Usage: newTask($name, $resource, \@target, \@source, \@deps, $prefix)
sub newTask {
	$class = $_[0];
	$this = SBuild::CompileTask->newTask($_[1], $_[2], $_[3], $_[4], $_[5]);
	$this->{prefix} = $_[6];
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
	my $path = SMakeParser::ProfileUtils::getFilePath($profile, "wsdl2h", "wsdl2h");
	# -- filename prefix
	my $prefix = $this->{prefix};
	return "$path -s -n $prefix -o " . 
	       $targets->[0]->getFullname($profile) . " " . 
	       $sources->[0]->getFullname($profile);
}

return 1;
