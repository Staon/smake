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

#  Linker composer
#
#  This object keeps list of linking projects and system libraries.
#  It handles project dependencies and it checks physical presence
#  of libraries in the repository.
package SMakeParser::LinkerComposer;

use SMakeParser::ProfileUtils;
use SBuild::ProjectListEmpty;
use SBuild::Option;
use SBuild::LibCache;
use File::Spec;

#  Ctor
#
#  Usage: newLinkerComposer
sub newLinkerComposer {
	my $class = $_[0];
	my $this = {
		libs => [],        # -- linked projects
		directlibs => [],  # -- projects added directly as arguments (without -l)
		syslibs => [],     # -- system libraries
		translibs => [],   # -- transitive libraries
	};
	# -- local library cache for non-stable library projects
	$this->{localcache} = SBuild::LibCache->newLibCache;
	bless $this, $class;
}

#  Append a linked project
#
#  Usage: appendLibrary($prjname)
sub appendLibrary {
	my $this = $_[0];
	push @{$this->{libs}}, $_[1];
}

#  Append a direct library
#
#  Usage: appendDirectLibrary($prjname)
sub appendDirectLibrary {
	my $this = $_[0];
	push @{$this->{directlibs}}, $_[1];
}

#  Append a transitive library
#
#  Usage: appendTransitiveLibrary($prjname)
sub appendTransitiveLibrary {
	my $this = $_[0];
	push @{$this->{translibs}}, $_[1];	
}

#  Remove a linked, a forced or a transitive library
#
#  Usage: removeLibrary($prjname)
sub removeLibrary {
	my $this = $_[0];
	my @newlist = map { $_ != $_[1] } @{$this->{libs}};
	$this->{libs} = \@newlist;
	@newlist = map { $_ != $_[1] } @{$this->{directlibs}};
	$this->{directlibs} = \@newlist;
	@newlist = map { $_ != $_[1] } @{$this->{translibs}};
	$this->{translibs} = \@newlist;
}

#  Append a system library
#
#  Usage: appendSysLibary($libname)
sub appendSysLibrary {
	my $this = $_[0];
	push @{$this->{syslibs}}, $_[1];
}

#  Remove a system library
#
#  Usage: removeSystemLibrary($prjname)
sub removeSystemLibrary {
	my $this = $_[0];
	my @newlist = map { $_ != $_[1] } @{$this->{syslibs}};
	$this->{syslibs} = \@newlist;
}

#  Create current project dependent on libraries
#
#  Usage: composeProjectDepenedencies($assembler, $profile, $reporter)
sub composeProjectDependencies {
	my $this = $_[0];
	my $assembler = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];

	# -- linked and forced libraries
	my @libs = (@{$this->{libs}}, @{$this->{directlibs}});
	foreach my $lib (@libs) {
		SMakeParser::ProfileUtils::addLibraryDependency($assembler, $lib);
	}
	
	# -- transitive libraries
	foreach my $lib (@{$this->{translibs}}) {
		SMakeParser::ProfileUtils::addProfileDependency($assembler, "libinst", $lib, "libinst");
	}
}

sub removeDuplicities {
	my $this = $_[0];
	
	# -- remove duplicities from the lists
	my %unique = map { $_, 1 } @{$this->{libs}};
	my @l1 = keys(%unique);
	$this->{libs} = \@l1;
	%unique = map { $_, 1 } @{$this->{directlibs}};
	my @l2 = keys(%unique);
	$this->{directlibs} = \@l2;
	%unique = map { $_, 1 } @{$this->{syslibs}};
	my @l3 = keys(%unique);
	$this->{syslibs} = \@l3;
}

sub getRawLibraries {
	my ($this, $profile, $reporter, $prjname) = @_;
	
	my $cache = $profile->getLibCache;
	if($cache->isCached($prjname)) {
		return (1, $cache->getListOfLibraries($prjname));
	}
	elsif($this->{localcache}->isCached($prjname)) {
		return (1, $this->{localcache}->getListOfLibraries($prjname));
	}
	else {
		# -- search the library project
		my $prjpath = $profile->getRepository->getProjectPath($prjname);
		if($prjpath) {
			#  run the library runner
			my $runner = SMakeParser::LibRunner->newLibRunner(
	                    	$::SMakeParser, $profile, $reporter, $prjname);
			my $seplist = SBuild::ProjectListEmpty->newProjectList;
			if (! $runner->parseSMakefile($prjpath, $runner, $seplist)) {
				$reporter->reportError("Project $prjname at $prjpath cannot be parsed! Maybe the project is deleted but it's still registered in the repository.");
				return (0, []);
			}
			
			# cache the libraries
			if($runner->isStable) {
				$cache->cacheData($prjname, $runner->getLibList);
			}
			else {
				$this->{localcache}->cacheData($prjname, $runner->getLibList);
			}
			return (1, $runner->getLibList);
		}
		else {
			$reporter->reportWarning("Project $prjname is not known and it cannot be linked.");
		}
	}
}

#  Update library cache according to the lists of libraries
#
#  Usage: updateLibraryCache($profile, $reporter)
#  Return: false when the update has failed.
sub updateLibraryCache {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];

	# -- here I resolve both libraries and direct libraries
	my @linkdeps = (@{$this->{libs}}, @{$this->{directlibs}});
	my $cache = $profile->getLibCache;
	foreach my $prj (@linkdeps) {
		my ($result, $list) = $this->getRawLibraries($profile, $reporter, $prj);
		return 0 if(! $result);
	}
	
	return 1;
}

#  Prepare the composer
#
#  The function updates the cache of libraries and removes duplicities from
#  the lists. This function should be called after last modification of library
#  list and immediatelly before getting of lists of libraries and linker
#  options.
#
#  Usage: prepareProcessing($profile, $reporter)
#  Return: false when the preparation failed
sub prepareProcessing {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	$this->removeDuplicities;
	return $this->updateLibraryCache($profile, $reporter);
}

#  Get list of library files
#
#  The function returns list of full paths of linked libraries. The list can be used
#  as a source for a decider. The function checks whether the library is taken from
#  the same repository as its project is registered.
#
#  Usage: getListOfLibraryFiles($profile, $reporter)
#  Return: \@librarylist or undef when a library isn't present in its repository
sub getListOfLibraryFiles {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	
	# -- create list of libraries (the list is composed by both libraries and
	#    direct libraries).
	my @linkdeps = (@{$this->{libs}}, @{$this->{directlibs}});
	my $cache = $profile->getLibCache;
	my $repository = $profile->getRepository;
	my @filelist = ();
	foreach my $prj (@linkdeps) {
		my ($result, $prjlibs) = $this->getRawLibraries($profile, $reporter, $prj);
		
		return undef if(! $result);
		foreach my $lib (@$prjlibs) {
			if(! File::Spec->file_name_is_absolute($lib)) { # -- exclude private libraries
				my $path = $repository->getLibraryFilePath($prj, $lib);
				if(! $path) {
					$reporter->reportError("Project $prj is registered in the repository, but its library $lib isn't installed. Compile and install it.");
					return undef;
				}
				push @filelist, $path;
			}
			else {
				push @filelist, $lib;
			}
		}
	}
	
	return \@filelist;
}

#  Get linker options
#
#  The function filles linking options into an option list
#
#  Usage: getLinkerOptions($optionlist, $profile, $reporter)
sub getLinkerOptions {
	my $this = $_[0];
	my $optionlist = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	
	my $repository = $profile->getRepository;
	
	# -- compose linker searching paths
	my @dirlist = reverse($repository->getLibraryDirectories);
	foreach my $dir (@dirlist) {
		$optionlist->prependOption(SBuild::Option->newOption(
						"", $profile->getToolChain->getLibDirOption($dir)));
	}
	
	# -- process usual libraries
	foreach my $prj (@{$this->{libs}}) {
		my ($result, $prjlibs) = $this->getRawLibraries($profile, $reporter, $prj);
		foreach my $lib (@$prjlibs) {
			$optionlist->appendOption(SBuild::Option->newOption(
						"", $profile->getToolChain->getLibOption($lib)));
		}
	}
	
	# -- process direct libraries
	foreach my $prj (@{$this->{directlibs}}) {
		my ($result, $prjlibs) = $this->getRawLibraries($profile, $reporter, $prj);
		foreach my $lib (@$prjlibs) {
			my $path = $repository->getLibraryFilePath($prj, $lib);
			if($path) {
				$optionlist->appendOption(SBuild::Option->newOption(
							"", $profile->getToolChain->getForceLibOption($path)));
			}
		}
	}
	
	# -- process system libraries
	foreach my $lib (@{$this->{syslibs}}) {
		$optionlist->appendOption(SBuild::Option->newOption(
						"", $profile->getToolChain->getLibOption($lib)));
	}
}

return 1;
