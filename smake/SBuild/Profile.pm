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

package SBuild::Profile;

use SBuild::ProfileStack;
use SBuild::Mangler;
use SBuild::LibCache;
use SBuild::ScannerList;
use SBuild::FileInstaller;
use SBuild::DirectoryEngine;

use SBuild::InstallEmptyRecord;
use SBuild::InstallHdrDirRecord;
use SBuild::InstallHdrFileRecord;
use SBuild::InstallLibRecord;

# Ctor
#  Usage: newProfile($runner, $decider, $toolchain, $installer, $repository, $named_profiles)
sub newProfile {
	my $class = $_[0];
	my $this = { 
		# -- configuration variables
		runner => $_[1],
		decider => $_[2],
		toolchain => $_[3],
		fileinstaller => $_[4],
		repository => $_[5],
		named_profiles => $_[6],
		
		# -- profile stack
		profstack => SBuild::ProfileStack->newProfileStack,
		# -- name mangler
		mangler => SBuild::Mangler->newMangler,
		# -- library cache
		libcache => SBuild::LibCache->newLibCache,
		# -- list of source scanners
		scannerlist => SBuild::ScannerList->newScannerList,
		# -- directory engine
		direngine => SBuild::DirectoryEngine->newEngine,
		# -- install loggers
		loggers => {},
		# -- records of install loggers
		logger_records => {
			'D' => SBuild::InstallHdrDirRecord->newRecord,
			'H' => SBuild::InstallHdrFileRecord->newRecord,
			'L' => SBuild::InstallLibRecord->newRecord,
			'N' => SBuild::InstallEmptyRecord->newRecord,
		},
	};
	
	bless $this, $class; 
}

# Get tool chain object
sub getToolChain {
	my $this = shift;
	return $this->{toolchain};
}

# Get file obsoletion decider
sub getDecider {
	my $this = shift;
	return $this->{decider};
}

# Get command runner
sub getRunner {
	my $this = shift;
	return $this->{runner};
}

# Get stack of compilation profiles
sub getProfileStack {
	my $this = shift;
	return $this->{profstack};
}

# Get project repository
sub getRepository {
	my $this = shift;
	return $this->{repository};
}

# Get list of named profiles
sub getNamedProfiles {
	my $this = shift;
	return $this->{named_profiles};
}

#  Get name mangler
sub getMangler {
	my $this = $_[0];
	return $this->{mangler};
}

#  Get libary cache
sub getLibCache {
	my $this = $_[0];
	return $this->{libcache};
}

#  Get factory of source scanners
sub getScannerList {
	my $this = $_[0];
	return $this->{scannerlist};
}

#  Get file installer
sub getFileInstaller {
	my $this = $_[0];
	return $this->{fileinstaller};
}

#  Get directory engine
sub getDirEngine {
	my $this = $_[0];
	return $this->{direngine};
}

#  Set current project
sub setCurrentProject {
	my $this = $_[0];
	$this->{current_project} = $_[1];
}

#  Clean current project
sub cleanCurrentProject {
	my $this = $_[0];
	delete $this->{current_project};
}

#  Get current project
sub getCurrentProject {
	my $this = $_[0];
	return $this->{current_project};
}

#  Usage: getInstallLogger($path)
sub getInstallLogger {
	my $this = $_[0];
	return $this->{loggers}->{$_[1]};
}

#  Usage: setInstallLogger($path, $logger)
sub setInstallLogger {
	my $this = $_[0];
	$this->{loggers}->{$_[1]} = $_[2];
}

#  Usage: cleanInstallLogger($path)
sub cleanInstallLogger {
	my $this = $_[0];
	delete $this->{loggers}->{$_[1]};
}

#  Register a record of the installer log
#
#  Usage: registerLoggerRecord($id, $record)
sub registerLoggerRecord {
	my ($this, $id, $record) = @_;
	$this->{logger_records}->{$id} = $record;
}

#  Get a installation log record
#
#  Usage: getLoggerRecord($id);
sub getLoggerRecord {
	my ($this, $id) = @_;
	return $this->{logger_records}->{$id};
}

return 1;
