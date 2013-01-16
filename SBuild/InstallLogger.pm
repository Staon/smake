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

#  Creating and storing of installation logs
package SBuild::InstallLogger;

my $Is_QNX = $^O eq 'qnx';

use File::Spec;
use File::Basename;
use SBuild::Dirutils;

if($Is_QNX) {
  require Digest::SHA::PurePerl;
  import Digest::SHA::PurePerl qw(sha1_hex);
}
else {
  require Digest::SHA;
  import Digest::SHA qw(sha1_hex);
}
  
#  Ctor
#
#  Usage: newLogger($profile, $path)
sub newLogger {
	my $class = $_[0];
	my $profile = $_[1];
	my $path = $_[2];

	my %logfile = ();
	
	# -- Create name of the log file. The name is computed as a hash
	#    from project's path.
	my $filename = $profile->getRepository->getLogDirectory;
	my $hashname = sha1_hex($path);
	$filename = File::Spec->catfile($filename, $hashname . ".log");
	
	# -- append project path and name into the log file
	$logfile{"S:" . $path} = 1;
	 
	# -- read content of the file
	if( -r $filename) {
		open(LOGFILE, "<$filename");
		while(defined(my $line = <LOGFILE>)) {
			chomp($line);    # -- trim the line
			$logfile{$line} = 1 if($line !~ /^[NS]:/);
		}
		close(LOGFILE);
	}
	
	my $this = {
		path => $path,
		filename => $filename,
		logfile => \%logfile
	};
	
	bless $this, $class;
}

#  Create new logger with content of a file
#
#  Usage: newLoggerFile($filename)
sub newLoggerFile {
	my $class = $_[0];
	my $filename = $_[1];

	my %logfile = ();
	my $path;
	
	# -- read content of the file
	local (* LOGFILE);
	open(LOGFILE, "<$filename") or die("It's not possible to open file $filename.");
	while(defined(my $line = <LOGFILE>)) {
		chomp($line);    # -- trim the line
		$logfile{$line} = 1;
		
		# -- parse location of the project
		if($line =~ /^S:/) {
			$path = $line;
			$path =~ s/^[^:]*://;
		}
	}
	close(LOGFILE);

	my $this = {
		path => $path,
		filename => $filename,
		logfile => \%logfile
	};
	bless $this, $class;
}

#  Append a log item
#
#  Usage: appendLogItem($profile, $id, $project, ...)
sub appendLogItem {
	my ($this, $profile, $id, $project, @args) = @_;
	
	# -- search the record
	my $record = $profile->getLoggerRecord($id);
	if(defined($record)) {
		# -- create the item
		my $item = $record->makeLogRecord($profile, $id, $project, @args);
		
		# -- store the item
		my $name = "";
		$name = $project->getName if(! $project->isAnonymous);
		$this->{logfile}->{"$id:$name:" . $item} = 1;
	}
	else {
		die "Invalid logging record " . $id . "!";
	}
}

#  Append a header directory
#
#  Usage: appendHeaderDirectory($profile, $project, $dir)
sub appendHeaderDirectory {
	my ($this, $profile, $project, $dir) = @_;
	$this->appendLogItem($profile, 'D', $project, $dir);
}

#  Append a directory file
#
#  Usage: appendHeaderFile($profile, $project, $prefix, $file)
#  Note: The $file must contain the project prefix
sub appendHeaderFile {
	my ($this, $profile, $project, $prefix, $file) = @_;
	$this->appendLogItem($profile, 'H', $project, $prefix, $file);
}

#  Append a library file
#
#  Usage: appendLibraryFile($profile, $project, $library)
sub appendLibraryFile {
	my ($this, $profile, $project, $library) = @_;
	$this->appendLogItem($profile, 'L', $project, $library);
}

#  Remove all files which were installed in this project
#
#  Usage: cleanProject($project, $profile, $reporter)
sub cleanProject {
	my $this = $_[0];
	my $project = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	
	my $name = ".*";
	if(defined($project)) {
		if($project->isAnonymous) {
			$name = "^\$";
		}
		else {
			$name = "^" . quotemeta($project->getName) . "\$";
		}
	}
	
	my @remove_list = ();
	
	foreach my $record (keys(%{$this->{logfile}})) {
		my ($type, $prjname, @args) = split(/:/, $record);
	
		if($type ne "S" && $prjname =~ $name) {
			# -- search the record
			my $logrecord = $profile->getLoggerRecord($type);
			if(defined($logrecord)) {
				$logrecord->cleanInstalledFiles($profile, $reporter, $type, $prjname, @args);
			}
			else {
				die "Unknown log record " . $type . "!";
			}
			
			# -- remove the record
			push @remove_list, $record;
		}
	}
	
	# -- clean processed records
	foreach my $record (@remove_list) {
		delete $this->{logfile}->{$record};
	}
}

#  Store the installation log
#
#  Usage: storeLog($profile, $reporter)
sub storeLog {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	if(scalar keys %{$this->{logfile}} > 1) {
		# -- create log directory if it's needed
		my $tgdir = dirname($this->{filename});
		my $msg = SBuild::Dirutils::makeDirectory($tgdir);
		if($msg) {
			$reporter->reportError("It's not possible to create the log directory: " . $msg);
			return 0;
		}
	
		# -- store the log file
		my $filename = $this->{filename};
		local (* LOGFILE);
		open(LOGFILE, ">$filename");
		foreach my $entry (keys(%{$this->{logfile}})) {
			print LOGFILE "$entry\n";
		}
		close(LOGFILE);
	}
	else {
		# -- the log is empty, remove the file
		unlink($this->{filename});
	}
	
	return 1;
}

#  Remove whole logfile
#
#  Usage: removeLog($profile, $reporter)
sub removeLog {
	my $this = $_[0];
	unlink($this->{filename});
}

#  Usage: get path of the project
sub getProjectPath {
	my $this = $_[0];
	return $this->{path};
}

return 1;
