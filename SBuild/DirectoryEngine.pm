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

# Working with directories and it's names
package SBuild::DirectoryEngine;

use SBuild::Directory;
use SBuild::DirectoryAbsolute;
use SBuild::DirectoryRelative;
use SBuild::Dirutils;

#  Ctor
#
#  Usage: newEngine([$target_dir])
sub newEngine {
	my $class = $_[0];
	my $this = {};
	
	# -- initialization of the source base directory
	$this->{base_src} = SBuild::Directory::createDirectory(SBuild::Dirutils::getCwd());
	my $target_dir = $_[1];
	$target_dir = File::Spec->curdir() if(! defined($target_dir));
	$this->{base_tg} = SBuild::Directory::createDirectory($target_dir);
	# -- current project path
	$this->{prj_dir} = SBuild::Directory::createDirectory(File::Spec->curdir());
	# -- target base mode
	$this->{target_base_mode} = 0;
	
	return bless $this, $class;
}

#  Get absolute source base
sub getSourceBase {
	my $this = $_[0];
	return $this->{base_src}->getAbsolute($this->{base_tg});
}

#  Get absolute target base
sub getTargetBase {
	my $this = $_[0];
	return $this->{base_tg}->getAbsolute($this->{base_src});
}

#  Get base path according to selected mode
sub getBase {
	my $this = $_[0];
	if($this->{target_base_mode}) {
		return $this->getTargetBase;
	}
	else {
		return $this->getSourceBase;
	}
}

#  Get absolute source directory
sub getSource {
	my $this = $_[0];
	my $base = $this->getSourceBase;
	return $this->{prj_dir}->getAbsolute($base);
}

#  Get absolute target directory
sub getTarget {
	my $this = $_[0];
	my $base = $this->getTargetBase;
	return $this->{prj_dir}->getAbsolute($base);
}

#  Get source or target directory according to selected mode
sub getWorking {
	my $this = $_[0];
	if($this->{target_base_mode}) {
		return $this->getTarget;
	}
	else {
		return $this->getSource;
	}
}

#  Get relative source base path
sub getSourceBasePath {
	my $this = $_[0];

	# -- compute the difference
	my $base = $this->getBase;
	my $target = $this->getSourceBase;
	return $base->computeDifference($target)->getPath;
}

#  Get relative target base path
sub getTargetBasePath {
	my $this = $_[0];
	
	# -- compute the difference
	my $base = $this->getBase;
	my $target = $this->getTargetBase;
	return $base->computeDifference($target)->getPath;
}

#  Set target base mode
sub setTargetBaseMode {
	my $this = $_[0];
	$this->{target_base_mode} = 1;
}

#  Set source base mode
sub setSourceBaseMode {
	my $this = $_[0];
	$this->{target_base_mode} = 0;
}

#  Change current project directory
sub changeProjectDir {
	my $this = $_[0];
	my $path = $_[1];

	my $dir = SBuild::Directory::createDirectory($path);
	if($dir->isAbsolute) {
		$dir = $this->getWorking->computeDifference($dir);
		! $dir->isAbsolute or
			die "Project path '" . $dir->getPath . "' isn't in current scope!";
	} 
	$this->{prj_dir} = $this->{prj_dir}->appendPath($dir);
}

#  Get current project directory
sub getProjectDir {
	my $this = $_[0];
	return $this->{prj_dir};
}

#  Set current project directory
sub setProjectDir {
	my $this = $_[0];
	$this->{prj_dir} = $_[1];
}

#  Get relative source directory
sub getSourceDirectory {
	my $this = $_[0];
	my $working = $this->getWorking;
	my $source = $this->getSource;
	return $working->computeDifference($source);
}

#  Get relative source path
sub getSourcePath {
	my $this = $_[0];
	return $this->getSourceDirectory->getPath;
}

#  Get absolute source path
sub getSourcePathAbsolute {
	my $this = $_[0];
	return $this->getSource->getPath;
}

#  Get relative target directory
sub getTargetDirectory {
	my $this = $_[0];
	my $working = $this->getWorking;
	my $target = $this->getTarget;
	return $working->computeDifference($target);
}

#  Get relative target path
sub getTargetPath {
	my $this = $_[0];
	return $this->getTargetDirectory->getPath;
}

#  Get absolute target path
sub getTargetPathAbsolute {
	my $this = $_[0];
	return $this->getTarget->getPath;
}

#  Get relative path to a source file
#
#  Usage: getSourceFile($file)
sub getSourceFile {
	my $this = $_[0];
	return $this->getSourceDirectory->appendFile($_[1]);
}

#  Get absolute path to a source file
#
#  Usage: getSourceFileAbsolute($file)
sub getSourceFileAbsolute {
	my $this = $_[0];
	return $this->getSource->appendFile($_[1]);
}

#  Get relative path to a target file
#
#  Usage: getTargetFile($file)
sub getTargetFile {
	my $this = $_[0];
	return $this->getTargetDirectory->appendFile($_[1]);
}

#  Get absolute path of a target file
#
#  Usage: getTargetFileAbsolute($file)
sub getTargetFileAbsolute {
	my $this = $_[0];
	return $this->getTarget->appendFile($_[1]);
}

return 1;
