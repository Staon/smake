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

# Installation log record: OProperty definition file
package SMakeParser::OPropertyInstallRecord;

use SBuild::InstallLoggerRecord;

@ISA = qw(SBuild::InstallLoggerRecord);

# Ctor
sub newRecord {
	my $class = $_[0];
	my $this = SBuild::InstallLoggerRecord->newRecord;
	bless $this, $class;
}

# Make a new logging record. The method returns a one line string in which
# all needed data are stored
#
# Usage: makeLogRecord($profile, $id, $project, ...)
sub makeLogRecord {
	my ($this, $profile, $id, $project, $deffile) = @_;
	return $deffile;
}

# Clean all installed files of this record
#
# Usage: cleanInstalledFiles($profile, $reporter, $id, $prjname, ...)
sub cleanInstalledFiles {
	my ($this, $profile, $reporter, $id, $prjname, $file) = @_;
	
	# -- name of the link
	my $target = $profile->getRepository->getModuleInstDirectory("oproperties");
	$target = File::Spec->catfile($target, $file);
	# -- report installation task
	$reporter->reportUninstall("uninstall OProperty definition file $target");
	# -- create the link
	unlink($target);
}

return 1;
