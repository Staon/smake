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

#  Install headers
package SBuild::HdrInstTask;

use SBuild::Task;
use SBuild::Dirutils;

use File::Spec;
use File::Path;

@ISA = qw(SBuild::Task);

#  Ctor
#
#  Usage: newTask($name, $resource, $tgname, $hdrdir)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{tgname} = $_[3];
	$this->{hdrdir} = $_[4];
	bless $this, $class;
}

sub getTargetName {
	my $this = $_[0];
	return $this->{tgname};
}

sub getTargetDirectory {
	my $this = $_[0];
	my $profile = $_[1];
	
	# -- name of the link
	my $tgdir = $profile->getRepository->getHdrInstDirectory;
	return File::Spec->catdir($tgdir, $this->{tgname});
}

sub getFakeDirectory {
	my $this = $_[0];
	my $profile = $_[1];
	
	# -- name of the directory
	my $dir = $profile->getRepository->getFakeDirectory;
	return File::Spec->catdir($dir, $this->{tgname});
}

#  Make target directory
#
#  Usage: prepareTargetPath($profile, $reporter, $project)
#  Return: false when the function fails
sub prepareTargetPath {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	my $tgfile = $this->getTargetDirectory($profile);	
	# -- create new directory
	my $msg = SBuild::Dirutils::makeDirectory($tgfile);
	if($msg) {
		$reporter->reportError("It's not possible to create header directory: " . $msg);
		return 0;
	}
	
	return 1;
}

#  Make the fake directory
#
#  Usage: prepareFakePath($profile, $reporter, $project)
#  Return: false when the function fails
sub prepareFakePath {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	my $fakedir = $this->getFakeDirectory($profile);
	if(! -d $fakedir) {
		my $msg = SBuild::Dirutils::makeDirectory($fakedir);
		if($msg) {
			$reporter->reportError("It's not possible to create the fake directory: " . $msg);
			return 0;
		}
	}
	
	return 1;
}

#  Clean target directory
#
#  Usage: cleanTargetPath($profile, $reporter, $project)
#  Return: true
sub cleanTargetPath {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $tgfile = $this->getTargetDirectory($profile);
	SBuild::Dirutils::removeDirectory($tgfile);	
	
	return 1;
}

return 1;
