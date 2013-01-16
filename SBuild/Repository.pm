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

#  Repository of projects - projects' paths
package SBuild::Repository;

use File::Spec;
use File::Basename;
use QNX4;
use SBuild::Utils;

#  Ctor
#
#  Usage: newRepository([\%modules])
#
#  Modules is a hash which the keys mean name of modules and the values mean
#  name of its directory in the repository
sub newRepository {
	my $class = $_[0];
	my $this = {
		repositories => [],
		paths => [],
		modules => $_[1],
	};
	
	# -- initialize the modules
	$this->{modules} = {} if(! defined($this->{modules}));
	$this->{modules}->{include} = ["include", "fakeinclude"];
	$this->{modules}->{lib} = "lib";
	
	bless $this, $class;
}

#  Read content of a repository file
#
#  Usage: readRepository($filename, $reporter)
#  Return: False when an error occurs.
sub readRepository {
	my $this = $_[0];
	my $filename = $_[1];
	my $reporter = $_[2];

	# -- report repository reading
	$reporter->reportRepository($filename);
	
	# -- create the repository structure
	my $rep = {};

	# -- read the file
	if( -r $filename) {
		local (* REPFILE);
		open(REPFILE, "<$filename");
		while(defined(my $line = <REPFILE>)) {
			chomp($line);    # -- trim the line
			(my $project, my $source, my $target) = split(':', $line);
			if($project && $source && $target) {
				$rep->{$project} = [$source, $target];
			}
		}
		close(REPFILE);
	}
	
	# -- store the repository
	my $list = $this->{repositories};
	push @$list, $rep;
	$list = $this->{paths};
	push @$list, $filename;

	return 1;
}

#  Construct name of file of the repository
#
#  Usage: getRepositoryName($path)
sub getRepositoryName {
	my $this = $_[0];
	my $path = $_[1];
	
	return File::Spec->catfile($path, ".smakerep");
}

#  Initialize the repository accordint to the environmnet
#  variable.
#
#  Usage: initializeRepository($reporter)
#  Return: False when an error occurs.
sub initializeRepository {
	my $this = $_[0];
	my $reporter = $_[1];
	
	# Get content of the environment variable
	my $repstring = $ENV{'SMAKE_REPOSITORY'};

	# -- parse parts of the variable
	my @reps = ();
	while($repstring) {
		$repstring =~ s/^\s+//;
		my $value = $repstring;
		if($repstring =~ /^`/ ) {
			# -- interpreted value
			$value =~ s/^`([^`]*)`.*$/$1/;
			$repstring =~ s/^`[^`]*[^:]*//;
			$repstring =~ s/^://;
			
			my $cmd = $value;
			$value = QNX4::backticks($cmd);
			if($?) {
				$reporter->reportError("It's not possible to run command '$cmd' to get configuration of the repository!");
				return 0;
			}
			chomp($value);   # -- trim the string
		}
		else {
			# -- fixed value
			$value =~ s/^([^:]*).*$/$1/;
			$repstring =~ s/^([^:]*)//;
			$repstring =~ s/^://;
		}

		push @reps, $value if($value !~ /^\s*$/ );
	}
	if(! @reps) {
		$reporter->reportError("There is no repository specified! Please set the variable SMAKE_REPOSITORY!");
		return 0;
	}
	
	#  Store repository for write operations
	$this->{writerep} = $this->getRepositoryName($reps[0]); 

	# Try to read all repositories
	my $expanded_string = "";
	foreach $rep (@reps) {
		my $fullname = $this->getRepositoryName($rep);
		return 0 if(! $this->readRepository($fullname, $reporter));
		$expanded_string .= $rep . ":";
	}
	$expanded_string =~ s/:$//;
	$ENV{'SMAKE_REAL_REPOSITORY'} = $expanded_string;

	return 1;
}

#  Get project path
#
#  Usage: getProjectPath($projectname)
#  Return: project path or undef
sub getProjectPath {
	my $this = $_[0];
	my $projectname = $_[1];

	foreach my $rep (@{$this->{repositories}}) {
		my $path = $rep->{$projectname};
		return $path->[0] if(defined($path));
	}
	
	return undef;
}

#  Get project path
#
#  Usage: getTargetProjectPath($projectname)
#  Return: project path or undef
sub getTargetProjectPath {
	my $this = $_[0];
	my $projectname = $_[1];

	foreach my $rep (@{$this->{repositories}}) {
		my $path = $rep->{$projectname};
		return $path->[1] if(defined($path));
	}
	
	return undef;
}

#  Set project path
#
#  Usage: setProjectPath($projectname, $source, $target)
sub setProjectPath {
	my $this = $_[0];
	my $projectname = $_[1];
	my $source = $_[2];
	my $target = $_[3];
	
	$this->{repositories}->[0]->{$projectname} = [$source, $target];
}

#  Clean project
#
#  Usage: cleanProject($projectname)
sub cleanProject {
	my $this = $_[0];
	my $projectname = $_[1];
	if(defined($this->{repositories}->[0]->{$projectname})) {
		delete $this->{repositories}->[0]->{$projectname};
	}
}

#  Save data of the top repository into a file
#
#  Usage: storeRepository
#  Return: False when an error occurs
sub storeRepository {
	my $this = $_[0];
	my $filename = $this->{paths}->[0];

	open(REPFILE, ">$filename");
	foreach $project (keys(%{$this->{repositories}->[0]})) {
		my $path = $this->{repositories}->[0]->{$project};
		my $source = $path->[0];
		my $target = $path->[1];
		print REPFILE "$project:$source:$target\n";
	}
	close(REPFILE);
	
	return 1;	
}

#  Get list of directories where libraries are installed
#
#  Usage: getLibraryDirectories
sub getLibraryDirectories {
	my $this = $_[0];
	return $this->getModuleDirectories("lib");
}

#  Get list of directories where libraries are installed
#
#  Usage: getLibraryDirectories
sub getIncludeDirectories {
	my $this = $_[0];
	return $this->getModuleDirectories("include");
}

#  Get list of directories of a module
#
#  Usage: getModuleDirectories($module_name)
sub getModuleDirectories {
	my $this = $_[0];

	my @list = ();

	# -- get directory name
	my $dirnames = $this->{modules}->{$_[1]};
	if($dirnames) {
		# -- iterate all repositories
		foreach my $path (@{$this->{paths}}) {
			my $pathdir = dirname($path);
			my $dirlist = SBuild::Utils::getArrayRef($dirnames);
			foreach my $dir (@$dirlist) {
				push @list, File::Spec->catdir($pathdir, $dir);
			}
		}
	}
	
	return @list;
}

#  Get path when to install headers
sub getHdrInstDirectory {
	my $this = $_[0];
	return $this->getModuleInstDirectory("include");
}

#  Get path when libraries are installed into
sub getLibInstDirectory {
	my $this = $_[0];
	return $this->getModuleInstDirectory("lib");
}

#  Get a path when files of a module are installed into
#
#  Usage: getModuleInstDirectory($module_name)
sub getModuleInstDirectory {
	my $this = $_[0];
	
	my $dirnames = $this->{modules}->{$_[1]};
	if($dirnames) {
		my $filename = dirname($this->{paths}->[0]);
		my $dirname = SBuild::Utils::getArrayRef($dirnames);
		return File::Spec->catdir($filename, $dirname->[0]);
	}
	return ();
}

#  Get fake directory
sub getFakeDirectory {
	my $this = $_[0];
	
	my $filename = dirname($this->{paths}->[0]);
	return File::Spec->catdir($filename, "fakeinclude");
}

#  Get path to the fake header
sub getFakeHeader {
	my $this = $_[0];

	# -- compose path	
	my $filename = dirname($this->{paths}->[0]);
	$filename = File::Spec->catfile($filename, "fake.h");
	
	# -- create the file if it doesn't exist
	if(! -r $filename) {
		local (* FAKEFILE);
		open(FAKEFILE, ">$filename");
		print FAKEFILE "#error \"This header has been removed from its project but it's still included!\"\n";
		close(FAKEFILE);
	}
	
	return $filename;
}

#  Get a directory to store the installation logs
sub getLogDirectory {
	my $this = $_[0];
	
	my $filename = dirname($this->{paths}->[0]);
	return File::Spec->catdir($filename, "log");
}

#  \brief Check existence of a library in the repository
#
#  The function finds the project and the repository which the
#  project is installed in. Then it checks if specified library
#  is installed here.
#
#  \return Full library path when the library is present in the
#          repository. Undef value otherwise.
#
#  Usage: checkLibrary($projectname, $libfile)
sub getLibraryFilePath {
	my $this = $_[0];
	my $projectname = $_[1];
	my $libfile = $_[2];

	# -- firstly, find the project
	foreach my $i (0..$#{@{$this->{repositories}}}) {
		if(exists $this->{repositories}->[$i]->{$projectname}) {
			# -- compose library path in the repository
			my $path = dirname($this->{paths}->[$i]);
			$path = File::Spec->catdir($path, "lib");
			$path = File::Spec->catfile($path, $libfile);
			
			# -- check library existence
			if(-r $path) {
				return $path;
			}
			else {
				return undef;
			}
		}
	}

	# -- project or library aren't found
	return undef;
}

#  Check validity of projects in the repository
#
#  Usage: checkRepository($reporter)
#  Return: false when an error isn't valid
sub checkRepository {
	my $this = $_[0];
	my $reporter = $_[1];
	my $repositories = $this->{repositories};

	my $retval = 1;	
	foreach my $i (0 .. $#{$repositories}) {
		my $repository = $repositories->[$i];
		my $path = $this->{paths}->[$i];

		$reporter->reportRepositoryBegin($path);
		
		foreach my $prj (keys(%$repository)) {
			my $prjpath = File::Spec->catfile($repository->{$prj}->[0], "SMakefile");
			my $okflag = (-r $prjpath) and (-f $prjpath);
			$reporter->reportRepositoryProjectStatus($path, $prj, $okflag);
			$retval = ($retval and $okflag); 
		}
		
		$reporter->reportRepositoryEnd($path);
	}
	
	return $retval;
}

#  Remove orphaned records in the user repository
#
#  Usage: removeOrphans($reporter)
sub removeOrphans {
	my $this = $_[0];
	my $reporter = $_[1];
	
	my $repository = $this->{repositories}->[0];
	my $path = $this->{paths}->[0];

	$reporter->reportRepositoryBegin($path);

	# -- search orphaned projects
	my @remove_list = ();
	foreach my $prj (keys(%$repository)) {
		my $prjpath = File::Spec->catfile($repository->{$prj}->[0], "SMakefile");
		if(! (-r $prjpath) || ! (-f $prjpath)) {
			push @remove_list, $prj;
		}
	}

	# -- remove the projects
	foreach my $prj (@remove_list) {
		delete $repository->{$prj};
		$reporter->reportRepositoryProjectUnreg($prj);
	}

	$reporter->reportRepositoryEnd($path);
}

return 1;
