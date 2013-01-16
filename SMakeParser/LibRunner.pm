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

#  Runner to resolve library dependencies
package SMakeParser::LibRunner;

use SMakeParser::TargetRunner;
use SBuild::ProjectListEmpty;

use File::Spec;
use File::Basename;

@ISA = qw(SMakeParser::TargetRunner);

#  Ctor
#
#  Usage: newLibRunner($parser, $profile, $reporter, $prjname)
sub newLibRunner {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	$this->{liblist} = [];
	$this->{prjname} = $_[4];
	$this->{stable} = 1;   # -- list of libraries are stable across projects
	$this->{active} = 0;
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	my $runner = SMakeParser::LibRunner->newLibRunner($this->{parser},
	                                                  $this->{profile}, 
	                                                  $this->{reporter});
	$runner->{liblist} = $this->{liblist};
	$runner->{prjname} = $this->{prjname};
	$runner->{stable} = $this->{stable};
	
	return $runner;
}

#  Set project name
#
#  Usage: setProjectName($prjname)
sub setProjectName {
	my $this = $_[0];
	my $prjname = $_[1];
	$this->{prjname} = $prjname;
}

#  begin a project
#
#  Usage: startProject($prjlist, $currprj)
sub startProject {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	
	# -- check project validity. When the project isn't valid,
	#    die the script. This is done to be safe when a programmer
	#    forgets to register or unregister a project
	if(! $this->checkProjectValidity($prjlist, $currprj)) {
		$this->{reporter}->reportError("Project " . $currprj->getName . " isn't registered in the repository! Call the 'smake reg' command.");
		die;
	}

	if($currprj->getName eq $this->{prjname}) {
		$this->{active} = 1;
	}
}

#  Stop the project
#
#  Usage: endProject
sub endProject {
	my $this = $_[0];
	$this->{active} = 0;
}

#  Get lib list
sub getLibList {
	my $this = $_[0];
	return $this->{liblist};	
}

#  Check if computed list of libraries is stable across projects (so it can be cached)
sub isStable {
	my $this = $_[0];
	return $this->{stable};
}

#  lib target
#
#  Usage: lib($prjlist, $currprj, $shared_profile, $libname, \@sources)
#  Return: True when the library target were processed.
sub lib {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $libname = $_[4];
	my $sources = $_[5];

	# -- append library into the list of libraries
	if($this->{active}) {
		my $libfile = $this->{profile}->getMangler->mangleLibrary($this->{profile}, $libname)
		              . $this->{profile}->getToolChain->getLibExtension;
		push @{$this->{liblist}}, $libfile;
	}

	return 1;
}

#  private library target
#
#  Usage: lib($prjlist, $currprj, $shared_profile, $libname, \@sources)
#  Return: True when the library target were processed.
sub privlib {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $libname = $_[4];
	my $sources = $_[5];

	# -- append library into the list of libraries
	if($this->{active}) {
		# -- library name
		my $libfile = $libname . $this->{profile}->getToolChain->getLibExtension;
		push @{$this->{liblist}}, File::Spec->catfile($currprj->getPath, $libfile);
		
		# Note: I use absolute path of the library instead of using of name and
		#       directory separetely because Watcom has too small buffer to
		#       create a list of library directories.
	}

	return 1;
}

#  Helper function - run itself transitively
#
#  run_transitives($prjlist, $currprj, $shared_profile, \@links)
sub run_transitives {
	my ($this, $prjlist, $currprj, $shared_profile, $links) = @_;

	my $liblist = $this->{liblist};
	# -- iterate all dependencies
	foreach my $prj (@$links) {
		#  get project path
		my $prjpath = $this->{profile}->getRepository->getProjectPath($prj);
		if($prjpath) {
			#  create lib runner
			my $runner = $this->cloneRunner;
			$runner->setProjectName($prj);
			# create own project list
			my $seplist = SBuild::ProjectListEmpty->newProjectList;
			# parse project's SMakefile
			return 0 if (! $runner->parseSMakefile($prjpath, $runner, $seplist));
			
			# don't store the libraries because they are alread in the list,
			# because the list is shared between runner instances
			$this->{stable} = $this->{stable} && $runner->isStable;
		}
	}
	
	return 1; 
}

#  Transitive link dependencies
#
#  Usage: translink($prjlist, $currprj, $shared_profile, \@links)
sub translink {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $links = $_[4];

	if($this->{active}) {
		return $this->run_transitives($prjlist, $currprj, $shared_profile, $links);
	}
	return 1;
}

#  Linking features
#
#  Usage: feature($prjlist, $currprj, $shared_profile, $name, \@offlinks, \@onlinks)
sub feature {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $name = $_[4];
	my $offlinks = SBuild::Utils::getArrayRef($_[5]);
	my $onlinks = SBuild::Utils::getArrayRef($_[6]);

	if($this->{active}) {
		# -- The features are dynamically switched according to the profiles. So
		#    this library cannot be stored in the cache, because it's changed
		#    in every project.
		$this->{stable} = 0;
		
		my $factive = $this->{profile}->getProfileStack->isFeatureActive($name);
		my $links;
		if($factive) {
			$links = $onlinks;
		}
		else {
			$links = $offlinks;
		}
		return $this->run_transitives($prjlist, $currprj, $shared_profile, $links);
	}
	return 1;	
}

#  Makefile project
#
#  Usage: make($prjlist, $currprj, $shared_profile, \%target_mapping, \%args)
sub make {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $target_mapping = $_[4];
	my $args = $_[5];

	if($this->{active}) {
		# -- public libraries
		my $liblist = SBuild::Utils::getArrayRef($args->{'libs'});
		foreach my $lib (@$liblist) {
			my $file = fileparse($lib);
			push @{$this->{liblist}}, $file;
		}
		# -- private libraries
		$liblist = SBuild::Utils::getArrayRef($args->{'privlib'});
		foreach my $lib (@$liblist) {
			push @{$this->{liblist}}, File::Spec->catfile($currprj->getPath, $lib);
		}
	}
		
	return 1;	
}

#  Autoconfig project
#
#  Usage: autoconfig($prjlist, $currprj, $shared_profile, $cfgcmd, $cfgstage, \%mapping, \%args)
sub autoconfig {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $cfgcmd = $_[4];
	my $cfgstage = $_[5];
	my $mapping = $_[6];
	my $args = $_[7];

	return $this->make($prjlist, $currprj, $shared_profile, $mapping, $args);	
}

return 1;
