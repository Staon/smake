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

#  Install a header file
package SMakeParser::OPropertyInstallTask;

use SBuild::Task;

@ISA = qw(SBuild::Task);

use SBuild::Dirutils;
use File::Spec;

#  Ctor
#
#  Usage: newTask($name, $resource, $tgname, $defres)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{tgname} = $_[3];
	$this->{defres} = $_[4];
	bless $this, $class;
}

#  Run the task
#
#   Usage: processTask(profile, reporter, $project)
#   Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	# -- name of the link
	my $tgdir = $profile->getRepository->getModuleInstDirectory("oproperties");
	my $tgfile = File::Spec->catfile($tgdir, $this->{tgname});
	# -- name of the source file
	my $srcfile = $this->{defres}->getAbsolute($profile);
	# -- report installation task
	$reporter->reportInstall("OProperty definition file $srcfile to $tgfile");
	# -- create the installation directory if it's needed
	my $msg = SBuild::Dirutils::makeDirectory($tgdir);
	if($msg) {
		$reporter->reportError("It's not possible to create oproperty installation directory: " . $msg);
		return 0;
	}

	# -- make a record in the install log
	#  Usage: appendLogItem($profile, $id, $project, ...)
	$project->getInstallLogger($profile)->appendLogItem(
		$profile, 'O', $project, $this->{tgname});

	# -- create the link
	unlink($tgfile);
	symlink($srcfile, $tgfile);
	
	return 1;
}

return 1;
