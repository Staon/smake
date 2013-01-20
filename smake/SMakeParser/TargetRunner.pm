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

#  Target runner
package SMakeParser::TargetRunner;

use SMakeParser::FileParser;
use SBuild::Chdir;

use SBuild::Directory;
use SBuild::DirectoryRelative;

#  Ctor
#
#  Usage: newStandardRunner($parser, $profile, $reporter)
sub newTargetRunner {
	my $class = $_[0];
	my $this = {
		parser => $_[1],
		profile => $_[2],
		reporter => $_[3],
		check_prj_validity => 1,
	};
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	die "It's not possible to call pure virtual method TargetRunner::cloneRunner!\n";
}

#  Parse a SMakefile recursively
#
#  Usage: parseSMakefile($path, $runner, $prjlist, $currprj)
#  Return: False when an error occurs
sub parseSMakefile {
	my $this = $_[0];
	my $path = $_[1];
	my $runner = $_[2];
	my $prjlist = $_[3];
	my $currprj = $_[4];

	my $reporter = $this->{reporter};
	my $profile = $this->{profile};
	
	# create new file parser
	my $file_parser = SMakeParser::FileParser->newFileParser(
	                       $this->{parser}, $runner, $prjlist, $currprj);
	
	# Change the directory
	my $chdir = SBuild::Chdir->newChdir;
	return 0 if(! $chdir->pushDir($path, $reporter));
	# Parse the make file
	my $info = $file_parser->parseFile("SMakefile", $profile, $reporter);
	# Get back previous directory
	return 0 if(! $chdir->popDir($reporter));
	
	return $info;
}

#  Specification of subdirectories
#
#  Usage: parseSubdirs($prjlist, $currprj, $shared_profile, \@subdirs)
sub parseSubdirs {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $subdirs = $_[4];
	
	my $profile = $this->{profile};
	my $reporter = $this->{reporter};
	
	foreach my $subdir (@$subdirs) {
		# create clone of the runner
		my $runner = $this->cloneRunner;
		
		# parse recursive SMakefile
		my $info = $this->parseSMakefile(
						$subdir,
						$runner, $prjlist, $currprj);
		
		return 0 if(! $info);
	}
	
	return 1;
}

#  It's called before parsing of SMakefiles. Note: it's called
#  only once before parsing of all the files not before ever file.
#
#  Usage: beforeParsing($profile, $reporter)
sub beforeParsing {
	
}

#  It's called after parsing of SMakefiles. Note: it's called
#  only once after parsing of all the files not before ever file.
#
#  Usage: afterParsing($profile, $reporter)
sub afterParsing {
	
}

# Turn off checking of project validity
sub dontCheckProjectValidity {
	my $this = $_[0];
	$this->{check_prj_validity} = 0;
}

#  Check project validity - whether the project has the same path in the
#  repository
#
#  Usage: checkProjectValidity($prjlist, $currprj)
sub checkProjectValidity {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];

	my $retval = 1;
	if(! $currprj->isAnonymous && $this->{check_prj_validity}) {
		#  the abs_path is used to get cannonical path to make a comparison
		my $prjpath = SBuild::Dirutils::getCwd($currprj->getPath);
		my $reppath = $this->{profile}->getRepository->getProjectPath($currprj->getName);
#		print "$prjpath =?= $reppath\n";
		$retval = 0;
		if(defined($reppath)) {
			$retval = $prjpath eq SBuild::Dirutils::getCwd($reppath);
		}
	}
	
	return $retval;
}

#  Copy internal data into a new instance of a runner
sub cloneInternalData {
	my $this = $_[0];
	my $runner = $_[1];
	$runner->{check_prj_validity} = $this->{check_prj_validity};
}

return 1;
