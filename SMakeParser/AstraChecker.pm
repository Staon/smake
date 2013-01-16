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

#  A runner who checks several common errors in SMakefiles
package SMakeParser::AstraChecker;

use SMakeParser::TargetRunner;

@ISA = qw(SMakeParser::TargetRunner);

use SBuild::ProjectList;
use QNX4;

#  Ctor
#
#  Usage: newAstraChecker($parser, $profile, $reporter)
sub newAstraChecker {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	my $runner = SMakeParser::AstraChecker->newAstraChecker(
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

	$this->{prjheader} = 0;
}

#  Stop the project
#
#  Usage: endProject
sub endProject {
	my $this = $_[0];
	if($this->{prjheader}) {
		print "\n";
	}
}

#  Report an error
#
#  Usage: reportError($currprj, $message, $hint)
sub reportError {
	my $this = $_[0];
	my $currprj = $_[1];
	my $message = $_[2];
	my $hint = $_[3];
	
	if(! $this->{prjheader}) {
		print "Project " . $currprj->getName . " at " . $currprj->getPath . "\n";
		$this->{prjheader} = 1;
	}
	
	print "  $message";
	if(defined($hint)) {
		print " - $hint"; 
	}
	print "\n";
}

#  Specification of subdirectories
#
#  Usage: subdirs($prjlist, $currprj, $shared_profile, \@subdirs)
sub subdirs {
	my $this = shift;
	return $this->parseSubdirs(@_);
}

#  Usage: checkProfile($currprj, $name, generic args)
sub checkProfile {
	my $this = shift;
	my $currprj = shift;
	my $name = shift;
	
	if($name eq "libgen") {	
		$this->reportError(
				$currprj,
				"profile 'libgen'", 
				"Never write this profile in any SMakefile but use the --profile switch!");
	}
	if(($name eq "qnxodbc") || ($name eq "soapodbc")) {
		$this->reportError(
				$currprj,
				"profile 'qnxodbc'",
				"Use more general profile 'odbc'.");
	}
	if(($name eq "memmap") || ($name eq "memtest") || ($name eq "warning") || 
	   ($name eq "relink") || ($name eq "rebuild") || ($name eq "profiler")) {
		$this->reportError(
				$currprj,
				"profile '$name'",
				"Use the --profile switch or append this profile into your configuration file.");
	}
}

#  Usage: profile($prjlist, $currprj, $shared_profile, $name, generic args)
sub profile {
	my $this = shift;
	my $prjlist = shift;
	my $currprj = shift;
	my $shared_profile = shift;
	my $name = shift;

	$this->checkProfile($currprj, $name, @_);
	
	return 1;
}

#  Specification of a named profile
#
#  Usage: profiletask($prjlist, $currprj, $shared_profile, $resid, $name, generic args)
sub profiletask {
	my $this = shift;
	my $prjlist = shift;
	my $currprj = shift;
	my $shared_profile = shift;
	my $resid = shift;
	my $name = shift;

	$this->checkProfile($currprj, $name, @_);
	
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

	foreach my $lib (@$linkdeps) {
		# -- my hack to system libraries
		if($lib =~ "^Sys[.]") {
			my $name = $lib;
			$name =~ s/^Sys[.]//;
			$this->reportError(
					$currprj,
					"system library hack '$name'",
					"Don't use this hack, use a profile instead of.");
		}
		
		# -- odbc libraries
		if(($lib eq "aodbc.lib") || ($lib eq "qnxodbc.lib") || 
		   ($lib eq "avesoapodbc.lib") || ($lib eq "aodbc_asoap.lib") ||
		   ($lib eq "dbwatch_cli.lib") || ($lib eq "aodbc_avedbacc.lib")) {
			$this->reportError(
		  			$currprj,
		  			"library '$lib'",
		  			"Use the profile 'odbc'.");
		}

		# -- xml libraries
		if(($lib eq "libexapt.a") || ($lib eq "libparsifal.lib") ||
		   ($lib eq "axml_expat_wrapper.lib") || ($lib eq "axml_parsifal_wrapper.lib") ||
		   ($lib eq "axml.lib") || ($lib eq "axmlgen.lib") || ($lib eq "axmlparse.lib")) {
			$this->reportError(
					$currprj,
					"library '$lib'",
					"Use the profile 'xml'.");   	
		}
		
		# -- LUA libraries
		if(($lib eq "lualib.lib") || ($lib eq "alua.lib")) {
			$this->reportError(
					$currprj,
					"library '$lib'",
					"Use the profile 'lua'.");   	
		}

		# -- status client
		if(($lib eq "statusclient.lib")) {
			$this->reportError(
					$currprj,
					"library '$lib'",
					"Use the profile 'statusclient'.");
		}
		
		# -- memtest library
		if(($lib eq "memtest.lib")) {
			$this->reportError(
					$currprj,
					"library '$lib'",
					"Never link the memtest.lib in the release version!");   	
		}
	}
	
	return 1;
}

#  Usage: checkSourceLength($currprj, \@sources)
sub checkSourceLength {
	my $this = $_[0];
	my $currprj = $_[1];
	my $sources = $_[2];
	
	foreach my $src (@$sources) {
		if(length($src) > 39) {
			$this->reportError(
					$currprj,
					"too long name",
					"Filename '$src' is too long. It cannot be imported into an SVN repository.");
		}
	}
}

#  Usage: checkLibrary($currprj, $libname, \@sources, \%args)
sub checkLibrary {
	my $this = $_[0];
	my $currprj = $_[1];
	my $libname = $_[2];
	my $sources = $_[3];
	my $args = $_[4];
	
	# -- check library name
	if($libname =~ /\.lib$/) {
		$this->reportError(
				$currprj,
				"'.lib' suffix",
				"Don't specify the '.lib' suffix in the name of the library.");
	}
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
	
	# -- check project and library name
	if($libname . ".lib" ne $currprj->getName) {
		$this->reportError(
				$currprj,
				"wrong project name",
				"Names of the project and of the library should be the same!");
	}
	# -- check the library
	$this->checkLibrary($currprj, $libname, $sources, $args);
	# -- check lengths of the sources
	$this->checkSourceLength($currprj, $sources);
	
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

	$this->checkLibrary($currprj, $libname, $sources, $args);
	$this->checkSourceLength($currprj, $sources);
	
	return 1;
}

#  Usage: checkBinPrjName($currprj, $binname)
sub checkBinPrjName {
	my $this = $_[0];
	my $currprj = $_[1];
	my $binname = $_[2];

	if($currprj->getName ne $binname) {
		$this->reportError(
				$currprj,
				"wrong project name",
				"Names of the project and of the binary file should be the same!");
	}	
}

#  Usage: checkPublicBinary($currprj, $binname, \@sources, \%args)
sub checkPublicBinary {
	my $this = $_[0];
	my $currprj = $_[1];
	my $binname = $_[2];
	my $sources = $_[3];
	my $args = $_[4];

	if(! defined($args->{'install'}) && ! defined($args->{'dontinstall'})) {
		$this->reportError(
				$currprj,
				"uninstalled binary",
				"The binary file '$binname' isn't installed into the runtime. Shouldn't it be installed? Use a Test*Exec directive or mark the project by the 'dontinstall' argument.");
	}
}

#  Usage: checkBinary($currprj, $binname, \@sources, \%args)
sub checkBinary {
	my $this = $_[0];
	my $currprj = $_[1];
	my $binname = $_[2];
	my $sources = $_[3];
	my $args = $_[4];
	
	if(defined($args->{'install'})) {
		# -- check installation path
		my $path = $args->{'install'};
		if(($path ne "bin") && ($path ne "apps") && ($path ne "sbin")) {
			$this->reportError(
					$currprj,
					"wrong installation path",
					"Currently there are only three directories in the runtime to install binaries: 'bin', 'sbin' and 'apps'!");
		}
		
		# -- check help message
		if(! defined($args->{'usefile'}) && ! defined($args->{'version'})) {
			$this->reportError(
					$currprj,
					"missing help",
					"A help message must be set when a binary is published. Use the 'version' or 'usefile' argument!");
		}
	}
	
	# -- check use message
	if(defined($args->{'usefile'})) {
		if(-f $binname) {
			my $usemsg = QNX4::backticks("use ./$binname");
			if($usemsg =~ /^(\s|\n)*$/) {
				$this->reportError(
						$currprj,
						"missing help",
						"The help message is empty. Fill a help text in the usage file '" . $args->{'usefile'} . "'.");
			}
		}
		else {
			$this->reportError(
					$currprj,
					"not compiled",
					"The binary '$binname' isn't compiled yet. I cannot check the help message.");
		}
	}
	
	# -- check ogetopt help message
	if(defined($args->{'version'})) {
		if(-f $binname) {
			my $usemsg = QNX4::backticks("./$binname --help");
			if($usemsg =~ /^(\s|\n)*$/) {
				$this->reportError(
						$currprj,
						"missing help",
						"The help message is empty. Fill a help text in the OGetopt2 subsystem.");
			}
		}
		else {
			$this->reportError(
					$currprj,
					"not compiled",
					"The binary '$binname' isn't compiled yet. I cannot check the help message.");
		}
	}
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

	$this->checkBinPrjName($currprj, $execname);
	$this->checkPublicBinary($currprj, $execname, $sources, $args);
	$this->checkBinary($currprj, $execname, $sources, $args);
	$this->checkSourceLength($currprj, $sources);
	
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

	$this->checkBinPrjName($currprj, $execname);
	$this->checkPublicBinary($currprj, $execname, $sources, $args);
	$this->checkBinary($currprj, $execname, $sources, $args);
	$this->checkSourceLength($currprj, $sources);

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

	$this->checkBinary($currprj, $execname, $sources, $args);
	$this->checkSourceLength($currprj, $sources);
	
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

	$this->checkBinary($currprj, $execname, $sources, $args);
	$this->checkSourceLength($currprj, $sources);

	return 1;	
}

return 1;
