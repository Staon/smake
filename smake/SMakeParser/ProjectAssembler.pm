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

#  Project assembler
package SMakeParser::ProjectAssembler;

use SBuild::Stage;

use SBuild::HdrDirInstTask;
use SBuild::HdrFileInstTask;
use SBuild::InstallTask;
use SBuild::RegTask;
use SBuild::UnregTask;
use SBuild::ProjectCleanTask;
use SMakeParser::MakeTask;
use SMakeParser::TdbDirTask;
use SMakeParser::AutoconfigTask;

use SBuild::IncludeProfile;
use SMakeParser::WdbLinkProfile;
use SMakeParser::LibLinkProfile;

use SMakeParser::Phase;
use SBuild::Utils;

use SMakeParser::LibRunner;
use SMakeParser::WdbRunner;

use SMakeParser::LinkerComposer;

use File::Basename;

#  Ctor
#
#  Usage: newProjectAssembler($prjlist, $project, $resolver)
sub newProjectAssembler {
	my $class = $_[0];
	my $this = {
		prjlist => $_[1],
		project => $_[2],
		resolver => $_[3],
		stages => {},
		linker_composer => SMakeParser::LinkerComposer->newLinkerComposer,
		wdbprjs => [],
		inclist => [],
		phases => {
		    'hdrgen' => SMakeParser::Phase->newPhase('hdrgen'),
			'lib' => SMakeParser::Phase->newPhase('lib'),
			'bin' => SMakeParser::Phase->newPhase('bin'),
			'test' => SMakeParser::Phase->newPhase('test'),
			'extra' => SMakeParser::Phase->newPhase('extra'),
			'ex' => SMakeParser::Phase->newPhase('ex'),  # -- examples
			'make' => SMakeParser::Phase->newPhase('make'), # -- A pseudostage for makefile based project. Only the cleaning list is used
		},
		nohdrgen => 0
	};
	bless $this, $class;
}

################################################################
#  Interface of the resolver records
################################################################
#  Set main resource name
#
#  Usage: setMainResource($resid)
sub setMainResource {
	my $this = $_[0];
	if(defined($this->{main_resource})) {
		die "Only one main resource can be specified in a project!";
	}
	$this->{main_resource} = $_[1];
}

#  Get name of the main resource
sub getMainResource {
	my $this = $_[0];
	return $this->{main_resource};
}

#  Get a stage object
#
#  Usage: getStage($stagename)
sub getStage {
	my $this = $_[0];
	my $stagename = $_[1];
	
	my $stage = $this->{stages}->{$stagename};
	if(! defined($stage)) {
		$stage = SBuild::Stage->newStage($stagename);
		$this->{stages}->{$stagename} = $stage; 
		# -- add a dependency node
		$this->{prjlist}->addDepNode($this->{project}->getName, $stagename);
	}
	return $stage;
}

#  Append a task (without phase translation)
sub appendRawTask {
	my $this = $_[0];
	my $stage = $_[1];
	my $task = $_[2];
	
	$this->getStage($stage)->appendTask($task);
}

#  Find a task (without phase modification)
#
#  Usage: getRawTask($stage, $taskname)
#  Return: the task or undef
sub getRawTask {
	my $this = $_[0];
	my $stage = $_[1];
	my $taskname = $_[2];
	return $this->getStage($stage)->getTask($taskname);
}

#  Add a new task with phase translation
sub appendTask {
	my $this = $_[0];
	my $stage = $_[1];
	my $task = $_[2];
	
	my $currphase = $this->{currphase};
	$currphase->appendTask($this, $stage, $task);
}

#  Find a task (without phase modification)
#
#  Usage: getRawTask($stage, $taskname)
#  Return: the task or undef
sub getTask {
	my $this = $_[0];
	my $stage = $_[1];
	my $taskname = $_[2];
	return $this->{currphase}->getTask($this, $stage, $taskname);
}

#  Add a new installation task (installation of the runtime)
#
#  Usage: appendInstallTask($task)
sub appendInstallTask {
	my ($this, $task) = @_;
	$this->appendRawTask("install", $task);
	$this->appendRawTask("fastinstall", $task);
}

#  Process main resource
sub processMainResource {
	my $this = $_[0];
	my $map = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	
	$this->{main_resource}->process($this, $map, $profile, $reporter);
}

#  Get current project
sub getProject {
	my  $this = $_[0];
	return $this->{project};
}

#  Get file resolver
sub getResolver {
	my $this = $_[0];
	return $this->{resolver};
}

#  Add a dependency between two projects and theirs stages
#
#  Usage: addProjectDependency($srcprj, $srcstage, $dstprj, $dststage)
sub addProjectDependency {
	my $this = $_[0];
	my $srcprj = $_[1];
	my $srcstage = $_[2];
	my $dstprj = $_[3];
	my $dststage = $_[4];
	my $prjlist = $this->{prjlist};
	
	$prjlist->addDepNode($srcprj, $srcstage);
	$prjlist->addDepNode($dstprj, $dststage);
	$prjlist->addDependency($srcprj, $srcstage, $dstprj, $dststage);
}

#  Add a dependency between stages of the project
#
#  Usage: addStageDependency($source, $target)
sub addStageDependency {
	my $this = $_[0];
	my $src = $_[1];
	my $target = $_[2];
	
	$this->addProjectDependency($this->{project}->getName, $src,
	                            $this->{project}->getName, $target);
}

#  Create installation task
#
#  Usage: appendInstallTask($instdir, $instres)
sub createInstallTask {
	my $this = $_[0];
	my $instdir = $_[1];
	my $instres = $_[2];
	
	# -- make installation tasks
	my $insttask = SBuild::InstallTask->newTask(
							"install:" . $instres->getPurename, undef,
							$instdir, $instres);
	$this->appendInstallTask($insttask);
}

#  Add linked libraries
#
#  Usage: addLink($project | \@projects)
sub addLink {
	my $this = $_[0];
	my $projects = SBuild::Utils::getArrayRef($_[1]); 
	foreach my $prj (@$projects) {
		$this->{linker_composer}->appendLibrary($prj);
	}
}

#  Add a forced library
#
#  Usage: addForceLink($project | \@projects)
sub addForceLink {
	my $this = $_[0];
	my $projects = SBuild::Utils::getArrayRef($_[1]); 
	foreach my $prj (@$projects) {
		$this->{linker_composer}->appendDirectLibrary($prj);
	}
}

#  Add transitive libraries
#
#  Usage: addTransitiveLink($project | \@projects)
sub addTransitiveLink {
	my $this = $_[0];
	my $projects = SBuild::Utils::getArrayRef($_[1]);
	foreach my $prj (@$projects) {
		$this->{linker_composer}->appendTransitiveLibrary($prj);
	}
}

#  Remove linked libraries
#
#  Usage: removeLink($project | \@projects)
sub removeLink {
	my $this = $_[0];
	my $projects = SBuild::Utils::getArrayRef($_[1]); 
	foreach my $prj (@$projects) {
		$this->{linker_composer}->removeLibrary($prj);
	}
}

#  Add a system library
#
#  Usage: addSysLink($project | \@projects)
sub addSysLink {
	my $this = $_[0];
	my $projects = SBuild::Utils::getArrayRef($_[1]); 
	foreach my $prj (@$projects) {
		$this->{linker_composer}->appendSysLibrary($prj);
	}
}

#  Remove a system library
#
#  Usage: removeSysLink($project | \@projects)
sub removeSysLink {
	my $this = $_[0];
	my $projects = SBuild::Utils::getArrayRef($_[1]); 
	foreach my $prj (@$projects) {
		$this->{linker_composer}->removeSysLibrary($prj);
	}
}

#  Get linker composer
sub getLinkerComposer {
	my $this = $_[0];
	return $this->{linker_composer};
}

#  Add a wdblink dependency
#
#  Usage: addWdbLink(\@wdblinks)
sub addWdbLink {
	my $this = $_[0];
	my $wdblinks = $_[1];
	
	push @{$this->{wdbprjs}}, @$wdblinks;
}

#  Add a header directory
#
#  Usage: addHdrDir($tgname, $hdrres)
sub addHdrDir {
	my $this = $_[0];
	my $tgname = $_[1];
	my $hdrres = $_[2];

	# Header directory installation task
	my $insttask = SBuild::HdrDirInstTask->newTask("inst:" . $tgname, undef, $tgname, $hdrres);
	$this->appendRawTask("hdrinst", $insttask);
}

#  Add paths into the include list
#
#  Usage: addInclude(\@dirs)
sub addInclude {
	my $this = $_[0];
	my $dirs = $_[1];
	push @{$this->{inclist}}, @$dirs;
}

#  Add Wdb files
#
#  Usage: addWdbFiles(\@files, \%args)
sub addWdbFiles {
	my $this = $_[0];
	my $files = $_[1];
	my $args = $_[2];
	
	# -- the installation is done only when the 'install' argument is
	#    present.
	if(exists($args->{'install'})) {
		# -- prepare installation path
		my $subdir = $args->{'subdir'};
		if(defined($subdir)) {
			$subdir = File::Spec->catdir("wgt", $subdir);
		}
		else {
			$subdir = "wgt";
		}
		
		foreach my $wdb (@$files) {
			$this->createInstallTask($subdir, SBuild::SourceResource->newResource($wdb));
		}
	}
}

#  Add extra files
#
#  Usage: addExtraFiles(\@files [, \%args])
sub addExtraFiles {
	my $this = $_[0];
	my $files = $_[1];
	my $args = $_[2];

	# for extra files only file existence checking task
	# is created.
	foreach my $file (@$files) {
		# -- a directory
		if(-d $file) {
			# TODO: install the directory
			return;
		}

		# -- a plain file
		my $resource = SBuild::SourceResource->newResource($file);
		my $task = SBuild::CheckFileTask->newTask($file, undef, $resource);
		$this->appendRawTask("extracompile", $task);
		
		if(defined($args) && defined($args->{install})) {
			my $insttask = SBuild::InstallTask->newTask(
								"install:" . $resource->getFilename,
								$resource,
								$args->{install},
								$resource);
			$this->appendInstallTask($insttask);
		}
	}	
}

#  Set NoHdrGen flag
sub setNoHdrGenFlag {
	my $this = $_[0];
	$this->{nohdrgen} = 1;
}

################################################################
#  Phase access
################################################################
#  Set current phase
#
#  Usage: setCurrentPhase($phasename)
sub setCurrentPhase {
	my $this = $_[0];
	my $phasename = $_[1];
	$this->{currphase} = $this->{phases}->{$phasename};
}

#  Append a clean target (into an active phase)
#
#  Usage: addClean($filename)
sub addClean {
	my $this = $_[0];
	my $filename = $_[1];
	
	# -- insert into an active phase
	my $phase = $this->{currphase};
	$phase->addClean($filename) if(defined($phase));
}

#  Append a directory with dependencies to clean
#
#  Usage: addDepCleanDir($dir)
sub addDepCleanDir {
	my $this = $_[0];
	my $dir = $_[1];
	
	my $phase = $this->{currphase};
	$phase->addDepCleanDir($dir) if(defined($phase));
}

#  Append an object file (into an active phase)
#
#  Usage: addObject($filename)
sub addObject {
	my $this = $_[0];
	my $filename = $_[1];
	
	# -- append into the object list
	my $phase = $this->{currphase};
	$phase->addObject($filename);
}

#  Get list of object files
sub getObjectFiles {
	my $this = $_[0];
	return $this->{currphase}->getObjectList;
}

sub getPhase {
	my $this = $_[0];
	return $this->{currphase};
}

################################################################
#  Basic smake tasks
################################################################
#  Create a makefile project
#
#  Usage: addMake(\%mapping, \%args)
sub addMake {
	my $this = $_[0];
	my $mapping = $_[1];
	my $args = $_[2];
	$args = {} if(!defined($args));
	
	# -- map makefile targets to the stages
	foreach my $stage (keys(%$mapping)) {
		my $target = $mapping->{$stage};
		
		# -- makefile check - existence of the makefile is checked before
		#    invoking of the target
		my $mkfilecheck = 0;
		if($target =~ /^mkfilecheck:/) {
			$target =~ s/^mkfilecheck://;
			$mkfilecheck = 1;
		}
		
		my $maketask = SMakeParser::MakeTask->newTask("make:" . $stage, undef, $target, $mkfilecheck);
		$this->appendRawTask($stage, $maketask);
	}
	
	# -- header directory installation
	my $hdrdirs = SBuild::Utils::getArrayRef($args->{'hdrdirs'});
	foreach my $hdrtwin (@$hdrdirs) {
		my $tgdir = $hdrtwin->[0];
		my $srcdir = $hdrtwin->[1];
		my $inst = SBuild::HdrDirInstTask->newTask(
								"inst:" . $tgdir,  undef,
								$tgdir, 
								SBuild::SourceDirectoryResource->newResource($srcdir));
		$this->appendRawTask("hdrinst", $inst);
	}
	
	# -- separated headers
	my $hdrs = SBuild::Utils::getArrayRef($args->{'hdrs'});
	foreach my $hdrtwin (@$hdrs) {
		my $tgdir = $hdrtwin->[0];
		my $hdr = $hdrtwin->[1];
		my $tghdr = fileparse($hdr);
		my $hdrres = SBuild::SourceResource->newResource($hdr);
		my $tghdrres = SBuild::SourceResource->newResource($tghdr);
		my $inst = SBuild::HdrFileInstTask->newTask("inst:" . $tghdr, undef, $tgdir, $hdrres);
		$this->appendRawTask("hdrinst", $inst);
	}

	# -- public libraries
	my $libs = SBuild::Utils::getArrayRef($args->{'libs'});
	foreach my $lib (@$libs) {
		my $tglib = fileparse($lib);
		my $libres = SBuild::TargetResource->newResource($lib);
		my $inst = SBuild::LibInstTask->newTask(
								"inst:" . $tglib, undef,
								$tglib, $libres);
		$this->appendRawTask("libinst", $inst);
	}

	# -- runtime installation
	my $instlist = $args->{'install'};
	$instlist = {} if(! defined($instlist));
	foreach my $instdir (keys(%$instlist)) {
		my $bins = SBuild::Utils::getArrayRef($instlist->{$instdir});
		foreach my $bin (@$bins) {
			my $binres = SBuild::TargetResource->newResource($bin);
			$this->createInstallTask($instdir, $binres);
		}
	}
}

#  Add an autoconfig task
#
#  This method adds a task based on the configure scripts. The make tasks
#  are used underneath.
#
#  Usage: addAutoconfig($cfgcmd, $cfgstage, \%mapping, \%args)
#     $cfgcmd .... a command to run the configure script (including the ./configure call)
#     $cfgstage .. a stage which the command should be run
#     \%mapping .. stage mapping (see the Make task)
#     \%args ..... other make arguments
sub addAutoconfig {
	my ($this, $cfgcmd, $cfgstage, $mapping, $args) = @_;

	# -- add the autoconfig task
	my $actask = SMakeParser::AutoconfigTask->newTask(
		"autoconfig:" . $cfgstage, undef, $cfgcmd, $args);
	$this->appendRawTask($cfgstage, $actask);
	$actask->appendCleanTasks($this);
	
	# -- add make tasks
	$this->addMake($mapping, $args);
}

#  Add a TDB directory
#
#  Usage: addTdb($dir)
sub addTdb {
	my $this = $_[0];
	my $dir = $_[1];
	
	my $task = SMakeParser::TdbDirTask->newTask(
						"install:" . $dir->getDirectory, undef, 
						$dir);
	$this->appendInstallTask($task);
}

################################################################
#  Project construction
################################################################
#  Extend the resource map
#
#  Usage: extendMap($map, $profile, $reporter)
sub extendMap {
	my $this = $_[0];
	my $map = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	my $project = $this->{project};

	# -- prepare compilation profiles to be accessible
	$project->pushProfileLists($profile->getProfileStack);
	
	# -- give compile profiles a chance
	$profile->getProfileStack->extendMap($map, $this, $profile);
	
	# -- remove compile profiles
	$project->popProfileLists($profile->getProfileStack);
}

#  Create project structure
#
#  Usage: flushProject($map, $profile, $reporter)
sub flushProject {
	my $this = $_[0];
	my $map = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	my $project = $this->{project};
	my $prjlist = $this->{prjlist};

	# -- prepare compilation profiles to be accessible
	$project->pushProfileLists($profile->getProfileStack);
	
	# -- give compile profiles a chance
	$profile->getProfileStack->changeProject($map, $this, $profile);
	
	# -- widget database list
	$this->{project}->appendProfile(
			SMakeParser::WdbLinkProfile->newCompileProfile($this->{wdbprjs}));

	# -- flush stages of all phases
	$_->flushPhase($this) foreach (values(%{$this->{phases}}));
	
	# -- add registration stages
	if(! $project->isAnonymous) {
		my $regtask = SBuild::RegTask->newTask("reg", undef, $project->getName);
		$this->appendRawTask("reg", $regtask);
		my $unregtask = SBuild::UnregTask->newTask("unreg", undef, $project->getName);
		$this->appendRawTask("unreg", $unregtask);
	}
	
	# -- cleaning of installed files
	my $uninstalltask = SBuild::ProjectCleanTask->newTask("projectclean", undef);
	$this->appendRawTask("project_clean", $uninstalltask);
	
	# -- create all stages
	$project->appendStage($_) foreach (values(%{$this->{stages}}));

	# -- append include profiles
	my @inclist = $profile->getRepository->getIncludeDirectories;
	$project->appendRepositoryProfile(SBuild::IncludeProfile->newCompileProfile(\@inclist));
	$project->appendProfile(SBuild::IncludeProfile->newCompileProfile($this->{inclist}));
	
	# -- append default stage dependencies
	my $exphase = $this->{phases}->{'ex'};
	my $testphase = $this->{phases}->{'test'};
	my $binphase = $this->{phases}->{'bin'};
	my $libphase = $this->{phases}->{'lib'};
	my $extraphase = $this->{phases}->{'extra'};
	my $hdrgenphase = $this->{phases}->{'hdrgen'};
	my $makephase = $this->{phases}->{'make'};

	# -- install phase (synchronized after all bin stages)
	$this->addProjectDependency($project->getName, "install",
	                            "SMakePseudoProject", "InstallSync");
	$this->addProjectDependency("SMakePseudoProject", "InstallSync",
	                            $project->getName, $binphase->getLastStage);
	
	# -- check phase (synchronized after all test stages)
	$this->addProjectDependency($project->getName, "check",
	                            "SMakePseudoProject", "CheckSync");
	$this->addProjectDependency("SMakePseudoProject", "CheckSync",
	                            $project->getName, $testphase->getLastStage);
	
	# -- example phase
	$exphase->composeDependencies($this);
	$exphase->makeDependent($this, $binphase);
	
	# -- test phase
	$testphase->composeDependencies($this);
	$testphase->makeDependent($this, $binphase);
	
	# -- bin phase
	$binphase->composeDependencies($this);
	$this->addStageDependency($binphase->getFirstStage, "libinst");

	# -- library install
	$this->addStageDependency("libinst", $libphase->getLastStage);

	# -- lib phase
	$libphase->composeDependencies($this);
	$libphase->makeDependent($this, $extraphase);
	
	# -- extra files phase
	$extraphase->composeDependencies($this);
	
	# -- make phase
	$makephase->composeDependencies($this);

	# -- generation of headers
	if(! $this->{nohdrgen}) {
		$this->addProjectDependency($this->{project}->getName, $extraphase->getFirstStage,
	    	                        "SMakePseudoProject", "HdrGenSync");
		$this->addProjectDependency("SMakePseudoProject", "HdrGenSync",
		                            $this->{project}->getName, "hdrgeninst");
		$this->addStageDependency("hdrgeninst", "hdrgen");
		$this->addStageDependency("hdrgen", $hdrgenphase->getLastStage);
		$hdrgenphase->composeDependencies($this);
		# -- synchronization of hdrinst stage (it must be called before
		#    all compile stages)
		$this->addProjectDependency($this->{project}->getName, $hdrgenphase->getFirstStage,
	    	                        "SMakePseudoProject", "HdrInstSync");
	}
	else {
		$this->addProjectDependency($this->{project}->getName, $extraphase->getFirstStage,
		                            "SMakePseudoProject", "HdrInstSync");
	}
	$this->addProjectDependency("SMakePseudoProject", "HdrInstSync",
	                            $this->{project}->getName, "hdrinst");
	
	# -- dependencies to linked libraries
	$this->{linker_composer}->composeProjectDependencies($this, $profile, $reporter);

	# -- uninstallation tasks
	$this->addStageDependency("unreg", "project_clean");
	
	# -- cleaning
	$this->addStageDependency("clean", "depclean");

	# -- remove compile profiles
	$project->popProfileLists($profile->getProfileStack);
}

return 1;
