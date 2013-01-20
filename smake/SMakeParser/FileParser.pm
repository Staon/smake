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

#  Parser of one SMakefile
package SMakeParser::FileParser;

use SBuild::Project;
use SBuild::ProfileList;
use SBuild::Dirutils;
use SMakeParser::ArgChecker;

use File::Spec;

#  Ctor
#
#  Usage:  newFileParser($parser, $target_runner, $prjlist [,$depsrc])
sub newFileParser {
	my $class = shift;
	my $this = {
		parser => $_[0],
		target_runner => $_[1],
		prjlist => $_[2],
		depsrc => $_[3],
		shared_profile => SBuild::ProfileList->newProfileList
	};
	bless $this, $class;
}

#  Parse a file
#
#  Usage: parseFile($filename, $profile, $reporter)
#  Return: OK or ERR
sub parseFile {
	my $this = $_[0];
	my $filename = $_[1];
	my $profile = $_[2];
	my $reporter = $_[3];
	
	# Push itself
	$this->{parser}->pushParser($this);
	# Store the profile and reporter
	$this->{profile} = $profile;
	$this->{reporter} = $reporter;

	# Full path of the SMakefile to report errors
	my $fullpath = SBuild::Dirutils::getCwd();
	$fullpath = File::Spec->catfile($fullpath, $filename);
	
	# Read (slurp) the script file
	if(! open(SCRIPTFILE, "<$filename")) {
		$reporter->reportError("It's not possible to open file $fullpath!");
		return 0;
	}
	my $holdTerminator = $/;
	undef $/;
	my $script = <SCRIPTFILE>;
	$/ = $holdTerminator;
	close(SCRIPTFILE);
	
	# Process the script file
	$this->{failure} = 0;
	my $info = eval $script;
	if(! $info) {
		$reporter->reportError("File $fullpath is wrong.");
		if($@) {
			$reporter->reportError("$@");
		}
		$this->{failure} = 1;
	}
	
	# Pop itself
	$this->{parser}->popParser;

	return ! $this->{failure};
}

#  Start a project section
#
#  Usage: startProject($name, \%args)
sub startProject {
	my $this = $_[0];
	my $name = $_[1];
	my $args = $_[2]; 
	my $anon = 0;
	
	# Allocate a project name if the project is anonymous
	if(! $name) {
		$name = $this->{parser}->getID("Anonymous", $name);
		$anon = 1;
	}
	
	# Get current path as a project path
	my $path = SBuild::Dirutils::getCwd();
	# Empty arguments if they are not specified
	$args = {} if(!defined($args));

	# -- create project structure
	my $project = SBuild::Project->newProject($name, $args, $anon, $path, $this->{shared_profile});
	$this->{currprj} = $project;
	# Initialize the runner
	my $target_runner = $this->{target_runner};
	if(defined($target_runner)) {
		$target_runner->startProject($this->{prjlist}, $project);
	}	
}

#  End a project section
#
#  Usage: endProject
sub endProject {
	my $this = $_[0];

	#  Construct the project
	if(defined($this->{target_runner})) {
		$this->{target_runner}->endProject;
	}	
	# Store the project
	$this->{prjlist}->appendProject($this->{currprj});
	# Clean the runner
	if(defined($this->{target_runner})) {
		$this->{target_runner} = $this->{target_runner}->cloneRunner;
	}
	# Set dependencies
#	$this->{parser}->addStageDependencies($this->{prjlist}, 
#	                                      $this->{depsrc}, 
#	                                      $this->{currprj});
	# Clean current project
	$this->{currprj} = undef;
}

#  Run a parser target
#
#  Usage: doParserTarget($target, other args)
sub doParserTarget {
	my $this = shift;
	my $target = shift;
	
	# Check if the target exists in the runner
	my $target_runner = $this->{target_runner};
	my $prjlist = $this->{prjlist};
	my $currprj = $this->{currprj};
	my $shared_profile = $this->{shared_profile};
	
	if(defined($target_runner) and $target_runner->can($target)) {
		my $info = $target_runner->$target($prjlist, $currprj, $shared_profile, @_);
		$this->{failure} = 1 if(! $info);
	}	
}

############################ SMakefile functions #############################

#  Begin a project
#
#  Usage: Project([$name, \%args])
sub Project {
	SMakeParser::ArgChecker::checkOptScalar($_[0], 1, "Project");
	SMakeParser::ArgChecker::checkOptHash($_[1], 2, "Project");
	
	$::SMakeParser->getTopParser->startProject(@_);
	return 0;
}

#  End a project
sub EndProject {
	$::SMakeParser->getTopParser->endProject;
	return 1;
}

#  Create a library
#
#  Usage: Lib($libname, \@sources, \%args)
sub Lib {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Lib");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "Lib");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "Lib");

	$::SMakeParser->getTopParser->doParserTarget("lib", @_);
	return 0;
}

#  Private library (it's not installed)
#
#  Usage: PrivLib($libname, \@sources, \%args)
sub PrivLib {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "PrivLib");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "PrivLib");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "PrivLib");

	$::SMakeParser->getTopParser->doParserTarget("privlib", @_);
	return 0;
}

#  Create a binary file
#
#  Usage: Exec($execname, \@sources, \%args)
sub Exec {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Exec");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "Exec");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "Exec");

	$::SMakeParser->getTopParser->doParserTarget("bin", @_);
	return 0;
}

#  Create a photon binary file
#
#  Usage: Exec($execname, \@sources, \%args)
sub PhExec {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "PhExec");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "PhExec");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "PhExec");

	$::SMakeParser->getTopParser->doParserTarget("phbin", @_);
	return 0;
}

#  Create a testing binary (a binary file which isn't an official
#  utility and should be compiled only in the testing stage)
sub TestExec {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "TestExec");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "TestExec");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "TestExec");

	$::SMakeParser->getTopParser->doParserTarget("testbin", @_);
	return 0;
}

#  Define a project which doesn't produce any main target
#
#  Usage: Empty(\@sources, \%args)
sub Empty {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "Empty");
	SMakeParser::ArgChecker::checkOptHash($_[1], 2, "Empty");

	$::SMakeParser->getTopParser->doParserTarget("empty", @_);
	return 0;
}

#  Create a testing Photon application (an application which ins't an
#  official part of the installation and should be compiled only in the
#  testing stage).
sub TestPhExec {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "TestPhExec");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "TestPhExec");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "TestPhExec");

	$::SMakeParser->getTopParser->doParserTarget("testphbin", @_);
	return 0;
}

#  Binary which is a generator of headers
sub HdrGen {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "HdrGen");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "HdrGen");
	SMakeParser::ArgChecker::checkOptHash($_[2], 3, "HdrGen");

	$::SMakeParser->getTopParser->doParserTarget("hdrgen", @_);
	return 0;
}

#  A project which is not dependent on a header generator
sub NoHdrGen {
	$::SMakeParser->getTopParser->doParserTarget("nohdrgen", @_);
	return 0;
}

#  Create a test runner
#
#  Usage: Test($testrunner, \@sources, $type)
#      $type:  'r' for cProces, 'p' for cPhotonProces, 's' for cSocketProces
sub Test {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Test");
	SMakeParser::ArgChecker::checkArray($_[1], 2, "Test");
	SMakeParser::ArgChecker::checkScalar($_[2], 3, "Test");
	SMakeParser::ArgChecker::checkOptHash($_[3], 4, "Test");

	$::SMakeParser->getTopParser->doParserTarget("test", @_);
	return 0;
}

#  Set a preprocesor variable to whole project
#
#  Usage: Preproc($variable, [$value])
sub Preproc {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Preproc");
	SMakeParser::ArgChecker::checkOptScalar($_[1], 2, "Preproc");

	$::SMakeParser->getTopParser->doParserTarget("preproc", @_);
	return 0;
}

#  Set a preprocessor variable to whole project. Value of the variable
#  is expected to be a C token which is used without quoting.
#
#  Usage: PreprocToken($variable, $value)
sub PreprocToken {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "PreprocToken");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "PreprocToken");
	
	$::SMakeParser->getTopParser->doParserTarget("preproc", $_[0], $_[1], 1);
	return 0;
}

#  Set a preprocesor variable to a task
#
#  Usage: PreprocTask($taskname, $variable, [$value])
sub PreprocTask {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "PreprocTask");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "PreprocTask");
	SMakeParser::ArgChecker::checkOptScalar($_[2], 3, "PreprocTask");

	$::SMakeParser->getTopParser->doParserTarget("taskpreproc", @_);
	return 0;
}

#  Set a preprocessor variable to a resource. Value of the variable
#  is expected to be a C token which is used without quoting.
#
#  Usage: PreprocTokenTask($taskname, $variable, $value)
sub PreprocTokenTask {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "PreprocTokenTask");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "PreprocTokenTask");
	SMakeParser::ArgChecker::checkScalar($_[2], 3, "PreprocTokenTask");
	
	$::SMakeParser->getTopParser->doParserTarget("taskpreproc", $_[0], $_[1], $_[2], 1);
}

#  Specification of subdirectories
#
#  Usage: Subdirs(\@subdirs)
sub Subdirs {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "Subdirs");
	
	$::SMakeParser->getTopParser->doParserTarget("subdirs", @_);
	return 0;
}

#  Specification of libraries to link
#
#  Usage: Link(\@links)
sub Link {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "Link");

	$::SMakeParser->getTopParser->doParserTarget("link", @_);
	return 0;
}

#  Transitive links
#
#  Usage: TransLink(\@links)
sub TransLink {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "TransLink");

	$::SMakeParser->getTopParser->doParserTarget("translink", @_);
	return 0;
}

#  Specification of a header directory
#
#  Usage: HeaderDir($linkname, $hdrdir)
sub HeaderDir {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "HeaderDir");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "HeaderDir");

	$::SMakeParser->getTopParser->doParserTarget("hdrdir", @_);
	return 0;
}

#  Specification of include directories
#
#  Usage: Include(\@dirs)
sub Include {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "Include");

	$::SMakeParser->getTopParser->doParserTarget("include", @_);
	return 0;
}

#  Specification of a compile profile
#
#  Usage: Profile($name, generic arguments)
sub Profile {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Profile");

	$::SMakeParser->getTopParser->doParserTarget("profile", @_);
	return 0;
}

#  Specification of a compile profile to a task
#
#  Usage: ProfileTask($taskname, $name, generic arguments)
sub ProfileTask {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "ProfileTask");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "ProfileTask");

	$::SMakeParser->getTopParser->doParserTarget("profiletask", @_);
	return 0;
}

#  User defined file resolver
#
#  Usage: Resolver($resolver)
sub Resolver {
	$::SMakeParser->getTopParser->doParserTarget("resolver", @_);
	return 0;
}

#  User defined dependencies of tasks
#
#  Usage: TaskDep($srctask, $dsttask)
sub TaskDep {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "TaskDep");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "TaskDep");

	$::SMakeParser->getTopParser->doParserTarget("taskdep", @_);
	return 0;
}

#  Define a variable of a compilation profile
#
#  Usage: ProfileVar($name, $value)
sub ProfileVar {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "ProfileVar");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "ProfileVar");

	$::SMakeParser->getTopParser->doParserTarget("profvar", @_);
	return 0;
}

#  Define a variable of a compilation profile of a task
#
#  Usage: ProfileVarTask($task, $var, $value)
sub ProfileVarTask {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "ProfileVarTask");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "ProfileVarTask");
	SMakeParser::ArgChecker::checkScalar($_[2], 3, "ProfileVarTask");

	$::SMakeParser->getTopParser->doParserTarget("profvartask", @_);
	return 0;
}

#  Define widget database files
#
#  Usage: Wdb(\@wdbfiles, \%args)
sub Wdb {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "Wdb");
	SMakeParser::ArgChecker::checkOptHash($_[1], 2, "Wdb");
	
	$::SMakeParser->getTopParser->doParserTarget("wdb", @_);
	return 0;
}

#  Specification of widget database files to link
#
#  Usage: WdbLink(\@wdblinks)
sub WdbLink {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "WdbLink");

	$::SMakeParser->getTopParser->doParserTarget("wdblink", @_);
	return 0;
}

#  Extra files which are not part of compilation
#
#  Usage: ExtraFiles(\@files [, \%args])
sub ExtraFiles {
	SMakeParser::ArgChecker::checkArray($_[0], 1, "ExtraFiles");
	SMakeParser::ArgChecker::checkOptHash($_[1], 2, "ExtraFiles");

	$::SMakeParser->getTopParser->doParserTarget("extrafiles", @_);
	return 0;
}

#  Manually specified dependency of the project
#
#  Usage: DependsOn($mystage, $dstprj, $dststage)
sub DependsOn {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "DependsOn");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "DependsOn");
	SMakeParser::ArgChecker::checkScalar($_[2], 3, "DependsOn");

	$::SMakeParser->getTopParser->doParserTarget("dependson", @_);
	return 0;
}

#  Create a makefile project
#
#  Usage: Make(\%target_mapping, \%args)
sub Make {
	SMakeParser::ArgChecker::checkHash($_[0], 1, "Make");
	SMakeParser::ArgChecker::checkOptHash($_[1], 2, "Make");
	
	$::SMakeParser->getTopParser->doParserTarget("make", @_);
	return 0;
}

#  Create an autoconfig project (the configure script and make)
#
#  Usage: Autoconfig($cfgcmd, $cfgstage, \%target_mapping, \%args)
sub Autoconfig {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Autoconfig");
	SMakeParser::ArgChecker::checkScalar($_[1], 2, "Autoconfig");
	SMakeParser::ArgChecker::checkHash($_[2], 3, "Autoconfig");
	SMakeParser::ArgChecker::checkOptHash($_[3], 4, "Autoconfig");
	
	$::SMakeParser->getTopParser->doParserTarget("autoconfig", @_);
	return 0;
}

#  Mark a directory with catalogues of messages
#
#  Usage: Tdb($dir)
sub Tdb {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Tdb");
	
	$::SMakeParser->getTopParser->doParserTarget("tdb", @_);
	return 0;
}

#  Add a task after another compilation task
#
#  Usage: TaskAfter($resource)
sub TaskAfter {
	$::SMakeParser->getTopParser->doParserTarget("taskafter", @_);
	return 0;
}

#  Specify a feature
#
#  Usage: Feature($name, $off_library, $on_library)
#    $name         Name of the feature
#    $off_library  A library project (or a list of projects) which is used
#                  when the feature is turned off
#    $on_library   A library project (or a list of projects) which is used
#                  when the feature is turned on
sub Feature {
	SMakeParser::ArgChecker::checkScalar($_[0], 1, "Feature");	
	SMakeParser::ArgChecker::checkScalarOrArray($_[1], 2, "Feature");	
	SMakeParser::ArgChecker::checkScalarOrArray($_[2], 3, "Feature");
	
	$::SMakeParser->getTopParser->doParserTarget("feature", @_);
	return 0;	
}

return 1;
