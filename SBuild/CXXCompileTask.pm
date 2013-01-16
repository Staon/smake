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

#  C++ compiler task
package SBuild::CXXCompileTask;

use SBuild::CompileTask;
use SBuild::Profile;

@ISA = qw(SBuild::CompileTask);

# Ctor
#   Usage: newTask($name, $resource, \@target, \@source, \@deps)
sub newTask {
	$class = shift;
	$this = SBuild::CompileTask->newTask(@_);
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
	my $targets = $this->convertToFileList($profile, $_[3]);
	my $sources = $this->convertToFileList($profile, $_[4]);
	my $options = $_[5];
	return $profile->getToolChain->getCXXCompiler($targets, $sources, $options);
}

#  Get task options
#
#  Usage: getOptions($profile, $reporter)
#  Return: String of the options
sub getOptions {
	my $profile = $_[1];
	my $reporter = $_[2];
	my $cflags = $profile->getProfileStack->getOptions("CXXFLAGS", $profile, $reporter);
	my $cppflags = $profile->getProfileStack->getOptions("CXXCPPFLAGS", $profile, $reporter);
	return "$cflags $cppflags";
}

return 1;
