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

#  Install a header directory
package SBuild::HdrDirInstTask;

use SBuild::HdrInstTask;

@ISA = qw(SBuild::HdrInstTask);

#  Ctor
#
#  Usage: newTask($name, $resource, $tgname, $hdrdir)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::HdrInstTask->newTask($_[1], $_[2], $_[3]);
	$this->{hdrdir} = $_[4];
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

	# -- name of the links
	my $tgfile = $this->getTargetDirectory($profile);
	my $srcfile = $this->{hdrdir}->getFullDirectoryAbsolute($profile);
	my $fakedir = $this->getFakeDirectory($profile);
	
	# -- report installation task
	$reporter->reportInstall("header dir $srcfile to $tgfile");

	# -- create target directories
	return 0 if(! $this->cleanTargetPath($profile, $reporter, $project));
	return 0 if(! $this->prepareTargetPath($profile, $reporter, $project));
	return 0 if(! $this->prepareFakePath($profile, $reporter, $project));
	
	# -- make a record in the install log
	$project->getInstallLogger($profile)->appendHeaderDirectory(
		$profile, $project, $this->getTargetName);

	# -- copy content of the header directory
	if(! SBuild::Dirutils::linkDirectoryContent($tgfile, $srcfile, '\$$')) {
		$reporter->reportError("It's not possible to link content of the header directory.");
		return 0;
	}
	# -- create fake headers
	if(! SBuild::Dirutils::linkFakeDirectoryContent($fakedir, $srcfile, $profile->getRepository->getFakeHeader, '\$$')) {
		$reporter->reportError("It's not possible to create fake headers of the header directory.");
		return 0;
	}
	
	return 1;
}
