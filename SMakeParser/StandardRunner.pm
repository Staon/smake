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

#  Standard parser runner
package SMakeParser::StandardRunner;

use SMakeParser::TargetRunner;

@ISA = qw(SMakeParser::TargetRunner);

use SMakeParser::ResourceMap;
use SMakeParser::ProjectAssembler;

use SBuild::SourceResource;
use SBuild::TargetResource;
use SBuild::SourceDirectoryResource;

use SMakeParser::FileResolver;
use SMakeParser::CXXRecord;
use SMakeParser::CRecord;
use SMakeParser::ObjectRecord;
use SMakeParser::MainRecord;
use SMakeParser::BisonRecord;
use SMakeParser::FlexRecord;
use SMakeParser::EmptyRecord;
use SMakeParser::TestRecord;
use SMakeParser::EmptyMainResource;
use SMakeParser::AssemblerRecord;

use SMakeParser::LibResource;
use SMakeParser::BinResource;
use SMakeParser::TestResource;

use SBuild::VarCompileProfile;
use SBuild::PreprocProfile;

#  Ctor
#
#  Usage: newStandardRunner($parser, $profile, $reporter)
sub newStandardRunner {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	
	my $resolver = SMakeParser::FileResolver->newFileResolver;
	$resolver->appendRecord(SMakeParser::CXXRecord->newRecord);
	$resolver->appendRecord(SMakeParser::CRecord->newRecord);
	$resolver->appendRecord(SMakeParser::AssemblerRecord->newRecord);
	$resolver->appendRecord(SMakeParser::ObjectRecord->newRecord);
	$resolver->appendRecord(SMakeParser::MainRecord->newRecord('[.]lib$'));
	$resolver->appendRecord(SMakeParser::MainRecord->newRecord('[.]exe$'));
	$resolver->appendRecord(SMakeParser::MainRecord->newRecord('^version:|^tail:|^usage:'));
	$resolver->appendRecord(SMakeParser::BisonRecord->newRecord);
	$resolver->appendRecord(SMakeParser::FlexRecord->newRecord);
	$resolver->appendRecord(SMakeParser::EmptyRecord->newRecord('[.]h(pp)?$'));
	$this->{resolver} = $resolver;
	
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	my $runner = SMakeParser::StandardRunner->newStandardRunner(
						$this->{parser},
	                    $this->{profile}, 
	                    $this->{reporter});
	$this->cloneInternalData($runner);
	return $runner;
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
	# -- report parsing of the project
	$this->{reporter}->reportProjectParsing($currprj->getName, $currprj->getPath);

	# -- create the resource map
	$this->{resource_map} = SMakeParser::ResourceMap->newResourceMap;
	$this->{phase} = '';

	# -- project assembler
	$this->{assembler} = SMakeParser::ProjectAssembler
	                        ->newProjectAssembler($prjlist, $currprj, $this->{resolver});
	
	# -- other data
	$this->{currprj} = $currprj;
	$this->{prjlist} = $prjlist;
}

#  Stop the project
#
#  Usage: endProject
sub endProject {
	my $this = $_[0];

	my $assembler = $this->{assembler};
	my $resolver = $this->{resolver};
	my $resource_map = $this->{resource_map};
	
	# -- 1st phase - extend resource map from source resources
	if(! $resource_map->extendMap($resolver, $assembler, $this->{profile}, $this->{reporter})) {
		die;
	}
	$assembler->extendMap($resource_map, $this->{profile}, $this->{reporter});
	# -- 2nd phase - create tasks from the map
	if(! $resource_map->processMap($resolver, $assembler, $this->{profile}, $this->{reporter})) {
		die;
	}
	
	# -- assembly the project
	$assembler->flushProject($resource_map, $this->{profile}, $this->{reporter});
	
	# -- report end of the project's parsing
	$this->{reporter}->reportEndOfParsing($this->{currprj}->getName, $this->{currprj}->getPath);
	
	return 1;
}

sub setMainResource {
	my $this = $_[0];
	my $phase = $_[1];
	my $resource = $_[2];
	my $sources = $_[3];
	
	my $assembler = $this->{assembler};
	my $resource_map = $this->{resource_map};
	
	$assembler->setCurrentPhase($phase);
	$assembler->setMainResource($resource->getID);
	$resource_map->appendResource($resource);
	$resource_map->appendSourceResources($sources);
}

#  lib target
#
#  Usage: lib($prjlist, $currprj, $shared_profile, $libname, \@sources, \%args)
#  Return: True when the library target were processed.
sub lib {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $libname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];
	my $resource_map = $this->{resource_map};

	my $main = SMakeParser::LibResource->newResource($libname . ".lib", 0, $args);
	$this->setMainResource('lib', $main, $sources);
	
	return 1;
}

#  private library
#
#  Usage: privlib($prjlist, $currprj, $shared_profile, $libname, \@sources, \%args)
#  Return: True when the library target were processed.
sub privlib {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $libname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];

	my $main = SMakeParser::LibResource->newResource($libname . ".lib", 1, $args);
	$this-> setMainResource('lib', $main, $sources);
	
	return 1;
}

#  create a regular binary file
#
#  Usage: bin($prjlist, $currprj, $shared_profile, $execname, \@sources, \%args)
#  Return: True when the binary target were processed.
sub bin {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $execname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];

	my $main = SMakeParser::BinResource->newResource($execname . ".exe", 0, $args);
	$this->setMainResource('bin', $main, $sources);
	
	return 1;
}

#  create a photon binary file
#
#  Usage: bin($prjlist, $currprj, $shared_profile, $execname, \@sources, \%args)
#  Return: True when the binary target were processed.
sub phbin {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $execname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];

	my $main = SMakeParser::BinResource->newResource($execname . ".exe", 1, $args);
	$this->setMainResource('bin', $main, $sources);

	return 1;	
}

#  create a header generator
#
#  Usage: hdrgen($prjlist, $currprj, $shared_profile, $execname, \@sources, \%args)
#  Return: True when the binary target were processed.
sub hdrgen {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $execname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];

	my $main = SMakeParser::BinResource->newResource($execname . ".exe", 0, $args);
	$this->setMainResource('hdrgen', $main, $sources);

	return 1;	
}

#  create a testing binary file
#
#  Usage: bin($prjlist, $currprj, $shared_profile, $execname, \@sources, \%args)
#  Return: True when the binary target were processed.
sub testbin {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $execname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];

	my $main = SMakeParser::BinResource->newResource($execname . ".exe", 0, $args);
	$this->setMainResource('ex', $main, $sources);
	
	return 1;
}

#  create a photon binary file
#
#  Usage: bin($prjlist, $currprj, $shared_profile, $execname, \@sources, \%args)
#  Return: True when the binary target were processed.
sub testphbin {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $execname = $_[4];
	my $sources = $_[5];
	my $args = $_[6];

	my $main = SMakeParser::BinResource->newResource($execname . ".exe", 1, $args);
	$this->setMainResource('ex', $main, $sources);

	return 1;	
}

#  test target
#
#  Usage: test($prjlist, $currprj, $shared_profile, $testrunner, \@sources, $type, \%args)
#      $type:  'r' for cProces, 'p' for cPhotonProces, 's' for cSocketProces
sub test {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $testrunner = $_[4];
	my $sources = $_[5];
	my $type = $_[6];
	my $args = $_[7];
	my $assembler = $this->{assembler};
	my $profile = $this->{profile};

	# -- Modify system resolver to handle test sources
	my $resolver = $this->{resolver};
	$resolver->appendSysRecord(SMakeParser::MainRecord->newRecord('^runtest:'));
	$resolver->appendSysRecord(SMakeParser::TestRecord->newRecord);
	$resolver->appendSysRecord(SMakeParser::CXXRecord->newRecord('[.]cc$'));

	# -- Main resource
	my $main = SMakeParser::TestResource->newResource($testrunner . ".exe", $args);
	$this->setMainResource('test', $main, $sources);
	
	# -- Set type of the process
#  Usage: newCompileProfile($name, $varname, $varvalue [, $prepend] )
	$type = "r" if(! defined($type));
	my $processtype = SBuild::VarCompileProfile->newCompileProfile(
		"", "OTEST_PROCESS", "-" . $type);
	$main->appendProfile($processtype);
	# -- set name of the regression file
	my $regression_file;
	if($args->{"regfile"}) {
		$regression_file = SBuild::VarCompileProfile->newCompileProfile(
				"", "OTEST_REGRESSION_FILE", "--regfile=" . $args->{"regfile"});
	}
	else {
		$regression_file = SBuild::VarCompileProfile->newCompileProfile(
				"", "OTEST_REGRESSION_FILE", "--regfile=regression.otest");
	}
	$main->appendProfile($regression_file);
	
	return 1;
}

#  empty project without any main resource
#
#  Usage: empty($prjlist, $currprj, $shared_profile, \@sources, \%args)
sub empty {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $sources = $_[4];
	my $args = $_[5];

	my $assembler = $this->{assembler};
	my $resource_map = $this->{resource_map};
	
	$assembler->setCurrentPhase("extra");
	$resource_map->appendSourceResources($sources);
	
	return 1;
}

#  Specification of subdirectories
#
#  Usage: subdirs($prjlist, $currprj, $shared_profile, \@subdirs)
sub subdirs {
	my $this = shift;
	return $this->parseSubdirs(@_);
}

sub appendResourceProfile {
	my $this = $_[0];
	my $resid = $_[1];
	my $profile = $_[2];
	
	$this->{resource_map}->appendProfile($resid, $profile);
}

sub appendProjectProfile {
	my $this = $_[0];
	my $currprj = $_[1];
	my $shared_profile = $_[2];
	my $profile = $_[3];

	if(defined($currprj)) {
		$currprj->appendProfile($profile);
	}
	else {
		$shared_profile->appendProfile($profile);
	}
}

#  Specification of include directories
#
#  Usage: include($prjlist, $currprj, $shared_profile, \@dirs)
sub include {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $dirs = $_[4];
	
	if(defined($currprj)) {
		$this->{assembler}->addInclude($dirs);
	}
	else {
		my $incprofile = SBuild::IncludeProfile->newCompileProfile($dirs);
		$shared_profile->appendProfile($incprofile);
	}
	
	return 1;
}

#  Set a profile variable
#
#  Usage: profvar($prjlist, $currprj, $shared_profile, $varname, $varvalue)
sub profvar {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $varname = $_[4];
	my $varvalue = $_[5];
	my $assembler = $this->{assembler};

	my $profile = SBuild::VarCompileProfile->newCompileProfile("", $varname, $varvalue);
	$this->appendProjectProfile($currprj, $shared_profile, $profile);
	return 1;
}

#  Set a profile variable of a task
#
#  Usage: profvartask($prjlist, $currprj, $shared_profile, $resid, $varname, $varvalue)
sub profvartask {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $resid = $_[4];
	my $varname = $_[5];
	my $varvalue = $_[6];
	
	my $profile = SBuild::VarCompileProfile->newCompileProfile("", $varname, $varvalue);
	$this->appendResourceProfile($resid, $profile);
	
	return 1;
}

#  Set a preprocessor variable to a task
#
#  Usage: taskpreproc($prjlist, $currprj, $shared_profile, $resid, $variable, $value, $tokenflag)
sub taskpreproc {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $resid = $_[4];
	my $variable = $_[5];
	my $value = $_[6];
	my $tokenflag = $_[7];
	
	$this->appendResourceProfile(
	              $resid, 
	              SBuild::PreprocProfile->newCompileProfile($variable, $value, $tokenflag));
	
	return 1;
}

#  Set a preprocessor variable to whole project
#
#  Usage: prjpreproc($prjlist, $currprj, $shared_profile, $variable, $value, $tokenflag)
sub preproc {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $variable = $_[4];
	my $value = $_[5];
	my $tokenflag = $_[6];

	my $profile = SBuild::PreprocProfile->newCompileProfile($variable, $value, $tokenflag);
	$this->appendProjectProfile($currprj, $shared_profile, $profile);	
	
	return 1;
}

#  Specification of a named profile
#
#  Usage: profile($prjlist, $currprj, $shared_profile, $name, generic args)
sub profile {
	my $this = shift;
	my $prjlist = shift;
	my $currprj = shift;
	my $shared_profile = shift;
	my $name = shift;

	# -- get named profile
	my $profile = $this->{profile}->getNamedProfiles->getNamedProfile($name, @_);
	$this->appendProjectProfile($currprj, $shared_profile, $profile) 
					if(defined($profile));
					
	return 1;
}

#  Specification of a named profile
#
#  Usage: profile($prjlist, $currprj, $shared_profile, $resid, $name, generic args)
sub profiletask {
	my $this = shift;
	my $prjlist = shift;
	my $currprj = shift;
	my $shared_profile = shift;
	my $resid = shift;
	my $name = shift;

	my $profile = $this->{profile}->getNamedProfiles->getNamedProfile($name, @_);
	$this->appendResourceProfile($resid, $profile);
	
	return 1;	
}

#  Resolve link dependencies
#
#  Usage: link($prjlist, $currprj, $shared_profile, \@linkdeps)
sub link {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $linkdeps = $_[4];
	
	my $profile = $this->{profile};
	my $reporter = $this->{reporter};
	my $assembler = $this->{assembler};

	$assembler->addLink($linkdeps);
	return 1;
}

#  Transitive link dependencies
#
#  Usage: translink($prjlist, $currprj, $shared_profile, \@links)
sub translink {
	my ($this, $prjlist, $currprj, $shared_profile, $links) = @_;

	$this->{assembler}->addTransitiveLink($links);
	return 1;
}

#  Include directory
#
#  Usage: hdrinst($prjlist, $currprj, $shared_profile, $linkname, $hdrdir)
sub hdrdir {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $linkname = $_[4];
	my $hdrdir = $_[5];
	
	my $dirres = SBuild::SourceDirectoryResource->newResource($hdrdir);
	$this->{assembler}->addHdrDir($linkname, $dirres);
	
	return 1;
}

#  User defined file resolver
#
#  Usage: resolver($prjlist, $currprj, $shared_profile, $resolver)
sub resolver {
	my $this = shift;
	my $prjlist = shift;
	my $currprj = shift;
	my $shared_profile = shift;
	my $resolver = shift;
	
	# -- append file resolver
	if(defined($resolver)) {
		$this->{resolver}->appendUserRecord($resolver);
	}
	
	return 1;	
}

#  Manually specified dependency
#
#  Usage: dependson($prjlist, $currprj, $shared_profile, $mystage, $dstprj, $dststage)
sub dependson {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $mystage = $_[4];
	my $dstprj = $_[5];
	my $dststage = $_[6];
	
	my $assembler = $this->{assembler};
	$assembler->addProjectDependency($currprj->getName, $mystage, $dstprj, $dststage);
	
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

	my $assembler = $this->{assembler};
	$assembler->setCurrentPhase('make');
	$assembler->addMake($target_mapping, $args);
	
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
	
	my $assembler = $this->{assembler};
	$assembler->setCurrentPhase('make');
	$assembler->addAutoconfig($cfgcmd, $cfgstage, $mapping, $args);
	
	return 1;
}

#  Directory with catalogues
#
#  Usage: tdb($prjlist, $currprj, $shared_profile, $dir)
sub tdb {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $dir = $_[4];
	
	my $assembler = $this->{assembler};
	$assembler->addTdb(SBuild::SourceDirectoryResource->newResource($dir));
	
	return 1;
}

#  User defined dependency of a task
#
#  Usage: taskdep($prjlist, $currprj, $shared_profile, $srctask, $dsttask)
sub taskdep {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $srctask = $_[4];
	my $dsttask = $_[5];

	my $resource_map = $this->{resource_map};
	$resource_map->appendDependency($srctask, $dsttask);
	
	return 1;
}

#  Wdblink dependency
#
#  Usage: wdblink($prjlist, $currprj, $shared_profile, \@wdblinks)
sub wdblink {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $wdblinks = $_[4];
	
	$this->{assembler}->addWdbLink($wdblinks);
	return 1;
}

#  Widget database files
#
#  Usage: wdb($prjlist, $currprj, $shared_profile, \@wdblist, \%args)
sub wdb {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $wdblist = $_[4];
	my $args = $_[5];
	
	# -- Wdb files of mine I use relatively, so I don't make
	#    whole absolute path.
	my $assembler = $this->{assembler};
	$assembler->addWdbFiles($wdblist, $args);
	
	return 1;
}

#  Mark this project as non-dependent on a header generator
sub nohdrgen {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	
	$this->{assembler}->setNoHdrGenFlag;
	return 1;
}

#  Add a task after another task
#
#  Usage: taskafter($prjlist, $currprj, $shared_profile, $tailres)
sub taskafter {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $tailres = $_[4];

	my $resource_map = $this->{resource_map};
	$resource_map->appendResource($tailres);
	
	return 1;
}

#  Add a list of extra files
#
#  Usage: extrafiles($prjlist, $currprj, $shared_profile, \@files [, \%args])
sub extrafiles {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $files = $_[4];
	my $args = $_[5];

	$this->{assembler}->addExtraFiles($files, $args);
	
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

	$this->{assembler}->addTransitiveLink($onlinks);
	$this->{assembler}->addTransitiveLink($offlinks);
	
	return 1;	
}

return 1;
