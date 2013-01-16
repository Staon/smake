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

#  Runner to check registration of projects
package SMakeParser::CheckRepositoryRunner;

use SMakeParser::TargetRunner;
use SBuild::ProjectList;

@ISA = qw(SMakeParser::TargetRunner);

#  Ctor
#
#  Usage: newCheckRepositoryRunner($parser, $profile, $reporter)
sub newCheckRepositoryRunner {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	my $runner = SMakeParser::CheckRepositoryRunner->newCheckRepositoryRunner(
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

	my $okflag = $this->checkProjectValidity($prjlist, $currprj);
	$this->{reporter}->projectRepositoryStatus($currprj->getName, $currprj->getPath, $okflag);
}

#  Stop the project
#
#  Usage: endProject
sub endProject {

}

#  Specification of subdirectories
#
#  Usage: subdirs($prjlist, $currprj, $shared_profile, \@subdirs)
sub subdirs {
	my $this = shift;
	return $this->parseSubdirs(@_);
}

#  It's called before parsing of SMakefiles. Note: it's called
#  only once before parsing of all the files not before ever file.
#
#  Usage: beforeParsing($profile, $reporter)
sub beforeParsing {
	my $this = $_[0];
	$this->{reporter}->projectCheckBegin;	
}

#  It's called after parsing of SMakefiles. Note: it's called
#  only once after parsing of all the files not after ever file.
#
#  Usage: afterParsing($profile, $reporter)
sub afterParsing {
	my $this = $_[0];
	$this->{reporter}->projectCheckEnd;
}

return 1;
