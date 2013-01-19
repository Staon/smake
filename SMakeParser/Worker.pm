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

#  Main worker
package SMakeParser::Worker;

use SBuild::Reporter;
use SBuild::ProjectListMemory;
use SBuild::ProjectListFile;
use SBuild::Repository;
use SBuild::NamedProfiles;
use SBuild::ProfileList;
use SBuild::ShellRunner;
use SBuild::TimeDecider;
use SBuild::GCCToolChain;
#use SBuild::WatcomToolChain;
use SBuild::Searcher;
use SBuild::Profile;

use SMakeParser::StandardRunner;
use SMakeParser::LibSearchRunner;
use SMakeParser::CheckRepositoryRunner;
use SMakeParser::AstraChecker;
use SMakeParser::EnchantLibrary;

use SMakeParser::MemtestProfile;
use SMakeParser::DebugProfile;
use SMakeParser::ProfilerProfile;
use SMakeParser::SocketProfile;
use SMakeParser::ODBCProfile;
use SMakeParser::SoapODBCProfile;
use SMakeParser::SybaseODBCProfile;
use SMakeParser::MemmapProfile;
use SMakeParser::ExceptionProfile;
use SMakeParser::TraceableProfile;
use SMakeParser::RebuildProfile;
use SMakeParser::PrivityT1Profile;
use SMakeParser::StackCheckProfile;
use SMakeParser::PhotonProfile;
use SBuild::SudoProfile;
use SMakeParser::RPCProfile;
use SMakeParser::XMLIncludeProfile;
use SMakeParser::InterruptHandlerProfile;
use SMakeParser::WarnDisableProfile;
use SMakeParser::SymtraceProfile;
use SMakeParser::RelinkProfile;
use SMakeParser::WarningProfile;
use SMakeParser::LuaProfile;
use SMakeParser::XMLProfile;
use SMakeParser::PerlProfile;
use SMakeParser::VersionProfile;
use SBuild::PreprocProfile;

use SMakeParser::StandardReporter;
use SMakeParser::XMLReporter;
use SMakeParser::ContainerReporter;

use SMakeParser::CScanner;
use SMakeParser::CXXScanner;

use SMakeParser::OPropertyInstallRecord;

use File::Spec;

#  Ctor
#
#  Usage: newWorker($verbosity [, $xmlfile])
sub newWorker {
	my $class = $_[0];
	my $this = {};
	
	# -- create reporters
	my $reporter = SMakeParser::StandardReporter->newReporter($_[1]);
	if(defined($_[2])) {
		$reporter = SMakeParser::ContainerReporter->newReporter(
						[ $reporter,
						  SMakeParser::XMLReporter->newReporter($_[2])
						]);
	}
	$this->{reporter} = $reporter;

	# -- Initialize named profiles
	$this->{named_profiles} = SBuild::NamedProfiles->newNamedProfiles;
	$this->{named_profiles}->appendNamedProfile("memtest", SMakeParser::MemtestProfile, 1);
	$this->{named_profiles}->appendNamedProfile("memtestlight", SMakeParser::MemtestProfile, 0);
	$this->{named_profiles}->appendNamedProfile("debug", SMakeParser::DebugProfile);
	$this->{named_profiles}->appendNamedProfile("profiler", SMakeParser::ProfilerProfile);
	$this->{named_profiles}->appendNamedProfile("socket", SMakeParser::SocketProfile);
	$this->{named_profiles}->appendNamedProfile("odbc", SMakeParser::ODBCProfile);
	$this->{named_profiles}->appendNamedProfile("soapodbc", SMakeParser::SoapODBCProfile);
	$this->{named_profiles}->appendNamedProfile("qnxodbc", SMakeParser::SybaseODBCProfile);
	$this->{named_profiles}->appendNamedProfile("memmap", SMakeParser::MemmapProfile);
	$this->{named_profiles}->appendNamedProfile("exception", SMakeParser::ExceptionProfile);
	$this->{named_profiles}->appendNamedProfile("traceable", SMakeParser::TraceableProfile);
	$this->{named_profiles}->appendNamedProfile("rebuild", SMakeParser::RebuildProfile);
	$this->{named_profiles}->appendNamedProfile("privityT1", SMakeParser::PrivityT1Profile);
	$this->{named_profiles}->appendNamedProfile("nostackcheck", SMakeParser::StackCheckProfile);
	$this->{named_profiles}->appendNamedProfile("photon", SMakeParser::PhotonProfile);
	$this->{named_profiles}->appendNamedProfile("sudo", SBuild::SudoProfile);
	$this->{named_profiles}->appendNamedProfile("rpc", SMakeParser::RPCProfile);
	$this->{named_profiles}->appendNamedProfile("xmldir", SMakeParser::XMLIncludeProfile);
	$this->{named_profiles}->appendNamedProfile("inthandler", SMakeParser::InterruptHandlerProfile);
	$this->{named_profiles}->appendNamedProfile("warndisable", SMakeParser::WarnDisableProfile);
	$this->{named_profiles}->appendNamedProfile("symtrace", SMakeParser::SymtraceProfile);
	$this->{named_profiles}->appendNamedProfile("relink", SMakeParser::RelinkProfile);
	$this->{named_profiles}->appendNamedProfile("warning", SMakeParser::WarningProfile);
	$this->{named_profiles}->appendNamedProfile("lua", SMakeParser::LuaProfile);
	$this->{named_profiles}->appendNamedProfile("xml", SMakeParser::XMLProfile);
	$this->{named_profiles}->appendNamedProfile("perl", SMakeParser::PerlProfile);
	$this->{named_profiles}->appendNamedProfile("makeversion", SMakeParser::VersionProfile);
	$this->{named_profiles}->appendNamedProfile("preproc", SBuild::PreprocProfile);

	# -- Initialize profile list
	$this->{proflist} = SBuild::ProfileList->newProfileList;

	bless $this, $class;
}

#  Read repositories of projects
#
#  Return: False when the reading fails
sub readRepository {
	my $this = $_[0];
	my $reporter = $this->{reporter};
	
	# -- Read project repository
	$this->{repository} = SBuild::Repository->newRepository({oproperties => "oproperties"});
	return $this->{repository}->initializeRepository($reporter);
}

#  Check repository - the method checks whether SMakefiles of all registered
#  projects in the repository exist.
#
#  Usage: checkRepository($check_flag)
sub checkRepository {
	my $this = $_[0];
	my $check_flag = $_[1];
	
	if($check_flag) {
		return $this->{repository}->checkRepository($this->{reporter});
	}
	else {
		return 1;
	}
}

#  Read configuration files
#
#  Usage: readConfigurationFiles($config_file)
sub readConfigurationFiles {
	my $this = $_[0];
	my $config_file = $_[1];
	
	# -- prepare paths
	my $user = File::Spec->catfile($ENV{HOME}, ".smakerc");
	my $global;
	if($config_file) {
		$global = $config_file;
	}
	else {
		# -- TODO: change the path to system wide configuration directory
		$global = File::Spec->catfile("/etc", "smakerc");
	}
	foreach $rcfile (($global, $user)) {
		if(-f $rcfile) {
			# Read (slurp) the script file
			open(SCRIPTFILE, "<$rcfile");
			my $holdTerminator = $/;
			undef $/;
			my $script = <SCRIPTFILE>;
			$/ = $holdTerminator;
			close(SCRIPTFILE);
	
			# Process the script file
			local $worker = $this;
			my $info = eval $script;
			if(! defined($info) and defined($@)) {
				warn "Error when a configuration file $rcfile is read: $@";
			}
		}
	}
	
	return 1;
}

#  Initialize smake environment
#  Note: the readRepository must be called before.
#
#  Usage: initEnvironment(\@profiles_list, $libvariant, $duplicate, $install)
sub initEnvironment {
	my $this = $_[0];
	my $profiles_list = $_[1];
	my $libvariant = $_[2];
	my $duplicate = $_[3];
	my $install = $_[4];
	
	# -- Prepare compilation environment
	my $cmdrunner = SBuild::ShellRunner->newRunner;
	my $decider = SBuild::TimeDecider->newDecider;
#	my $toolchain = SBuild::WatcomToolChain->newToolChain;
    my $toolchain = SBuild::GCCToolChain->newToolChain;
	my $installer = SBuild::FileInstaller->newFileInstaller($duplicate, $install);
	$this->{profile} = SBuild::Profile->newProfile(
	          $cmdrunner, $decider, $toolchain, $installer,
	          $this->{repository}, $this->{named_profiles});
	$this->{profile}->getMangler->setLibSuffix($libvariant);
	
	# -- Insert specified profiles 
	my $proflist = $this->{proflist};
	my $named_profiles = $this->{named_profiles};
	foreach my $prof (@$profiles_list) {
		# -- parse profile options
		my $name;
		my @arglist;
		if($prof =~ /\)/) {
			$name = $prof;
			$name =~ s/\(.*$//;
			my $args = $prof;
			$args =~ s/^[^(]*\(|\)$//g;
			@arglist = split(/,/, $args); 
		}
		else {
			$name = $prof;
			@arglist = ();
		}
		# -- create and append the profile
		my $cprofile = $named_profiles->getNamedProfile($name, @arglist);
		$proflist->appendProfile($cprofile) if(defined($cprofile));
	}
	
	# -- prepare scanners of source files
	$this->{profile}->getScannerList->registerScanner("cscanner", SMakeParser::CScanner);
	$this->{profile}->getScannerList->registerScanner("cxxscanner", SMakeParser::CXXScanner);
	
	# -- register my records of the installation log
	$this->{profile}->registerLoggerRecord('O', SMakeParser::OPropertyInstallRecord->newRecord);
	
	return 1;
}

#  Create a target runner
#
#  Usage: createRunner($parser, $libsearch, $checkrepository, $astracheck, $enchant)
sub createRunner {
	my $this = $_[0];
	my $parser = $_[1];
	my $libsearch = $_[2];
	my $checkrepository = $_[3];
	my $astracheck = $_[4];
	my $enchant = $_[5];

	my $profile = $this->{profile};
	my $reporter = $this->{reporter};
	
	if($libsearch) {
		$this->{runner} = SMakeParser::LibSearchRunner->newLibSearchRunner($parser, $profile, $reporter, $libsearch);
	}
	elsif($checkrepository) {
		$this->{runner} = SMakeParser::CheckRepositoryRunner->newCheckRepositoryRunner($parser, $profile, $reporter);
	}
	elsif($astracheck) {
		$this->{runner} = SMakeParser::AstraChecker->newAstraChecker($parser, $profile, $reporter);
	}
	elsif($enchant) {
		$this->{runner} = SMakeParser::EnchantLibrary->newRunner($parser, $profile, $reporter, $enchant);
	}
	else {
		$this->{runner} = SMakeParser::StandardRunner->newStandardRunner($parser, $profile, $reporter);
	}
}

#  Read SMakefiles
#
#  Usage: readFiles($parser, $search, $dont_check, $memory)
sub readFiles {
	my $this = $_[0];
	my $parser = $_[1];
	my $search = $_[2];
	my $dont_check = $_[3];
	my $memory = $_[4];

	my $profile = $this->{profile};
	my $reporter = $this->{reporter};
	my $runner = $this->{runner};
	
	if($dont_check) {
		$runner->dontCheckProjectValidity;
	}	

	# -- project list
	if($memory) {
		$this->{prjlist} = SBuild::ProjectListFile->newProjectList;
	}
	else {
		$this->{prjlist} = SBuild::ProjectListMemory->newProjectList;
	}

	$runner->beforeParsing($profile, $reporter);

	# -- parse the files
	my $retval = 1;
	if(! $search) {
		# -- only one SMakefile in the current directory
		$profile->getProfileStack->pushList($this->{proflist});
		my $fileparser = SMakeParser::FileParser->newFileParser($parser, $runner, $this->{prjlist});
		my $info = $fileparser->parseFile("SMakefile", $profile, $reporter);
		$profile->getProfileStack->popList;
		$retval = $info;
	}
	else {
		# -- search recursively SMakefiles
		my $searcher = SBuild::Searcher->newSearcher;
		my $dirlist = $searcher->search("SMakefile");
		my $chdir = SBuild::Chdir->newChdir;
		$retval = 1;
		foreach $dir (@$dirlist) {
			$chdir->pushDir($dir, $reporter);
			$profile->getProfileStack->pushList($this->{proflist});
			my $fileparser = SMakeParser::FileParser->newFileParser($parser, $runner, $this->{prjlist});
			my $info = $fileparser->parseFile("SMakefile", $profile, $reporter);
			$profile->getProfileStack->popList;
			$chdir->popDir($reporter);
			if(! $info) {
				$retval = 0;
				last;
			}
		}
	}
	
	$runner->afterParsing($profile, $reporter);

	return $retval;
}

#  Run stages
#
#  Usage: runStages(\@stages, $force [, $filter])
#  Return: False when the run fails
sub runStages {
	my $this = $_[0];
	my $stages = $_[1];
	my $force = $_[2];
	my $filter = $_[3];
	
	my $profile = $this->{profile};

	# -- Append the compilation profile list into the profile
	my $proflist = $this->{proflist};
	$profile->getProfileStack()->pushList($proflist);

	# -- Compute topological order and run the stages
	my $prjlist = $this->{prjlist};
	my $reporter = $this->{reporter};
	
	(my $result, my $processlist) = $prjlist->getProcessList($stages, $filter);
	if($result) {
		# -- report beginning of compilation
		$reporter->reportStartOfCompilation;
		
		# -- run the compilation
		my $info = $prjlist->initProcessing($profile, $reporter);
		$info = $prjlist->processList($processlist, $profile, $reporter, $force) && $info;
		$info = $prjlist->cleanProcessing($profile, $reporter) && $info;
		
		# -- report end of the compilation
		$reporter->reportEndOfCompilation;
		
		return $info;
	}
	else {
		$reporter->reportProjectCycle($processlist);
		return 0;
	}
}

#  Store project repository
sub storeRepository {
	my $this = $_[0];
	return $this->{repository}->storeRepository;
}

###################### Configuration files directives ######################
#  Append a compilation profile
#
#  Usage: appendProfile($profile)
sub appendProfile {
	my $this = $_[0];
	my $profile = $_[1];

	my $proflist = $this->{proflist};	
	$this->{proflist}->appendProfile($profile);
}

#  Register a named profile
#
#  Usage: registerNamedProfile($name, $module [, @args...])
sub registerNamedProfile {
	my $this = shift;
	$this->{named_profiles}->appendNamedProfile(@_);
}

return 1;
