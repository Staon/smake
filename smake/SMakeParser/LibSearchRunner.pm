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

#  Target runner to search projects which link a library
package SMakeParser::LibSearchRunner;

use SMakeParser::TargetRunner;
use SBuild::ProjectList;

use File::Spec;

@ISA = qw(SMakeParser::TargetRunner);

#  Ctor
#
#  Usage: newLibSearchRunner($parser, $profile, $reporter, $libprj)
sub newLibSearchRunner {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	$this->{libprj} = $_[4];
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	my $runner = SMakeParser::LibSearchRunner->newLibSearchRunner(
	                 $this->{parser},
	                 $this->{profile}, 
	                 $this->{reporter},
	                 $this->{libprj});
	$this->cloneInternalData($runner);
	return $runner;
}

#  begin a project
#
#  Usage: startProject($prjlist, $currprj)
sub startProject {
	#print "Start: " . $_[2]->getName . "\n";
}

#  Stop the project
#
#  Usage: endProject
sub endProject {

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
	
	foreach my $link (@$linkdeps) {
		if($link eq $this->{libprj}) {
			$currprj->printItself;
		}
	}
	
	return 1;
}

#  Specification of subdirectories
#
#  Usage: subdirs($prjlist, $currprj, $shared_profile, \@subdirs)
sub subdirs {
	my $this = shift;
	return $this->parseSubdirs(@_);
}

return 1;
