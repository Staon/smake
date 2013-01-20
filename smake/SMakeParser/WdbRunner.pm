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

#  Runner to resolve wdb dependencies
package SMakeParser::WdbRunner;

use SMakeParser::TargetRunner;
use SBuild::ProjectList;

use File::Spec;

@ISA = qw(SMakeParser::TargetRunner);

#  Ctor
#
#  Usage: newWdbRunner($parser, $profile, $reporter, $prjname)
sub newWdbRunner {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	$this->{wdbfiles} = [];
	$this->{prjname} = $_[4];
	$this->{active} = 0;
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	my $runner = SMakeParser::WdbRunner->newWdbRunner($this->{parser},
	                                                  $this->{profile}, 
	                                                  $this->{reporter},
	                                                  $this->{prjname});
	$runner->{wdbfiles} = $this->{wdbfiles};
	
	return $runner;
}

#  begin a project
#
#  Usage: startProject($prjlist, $currprj)
sub startProject {
	my $this = $_[0];
	my $currprj = $_[2];
	
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

#  Get wdb files list
sub getWdbList {
	my $this = $_[0];

	return @{$this->{wdbfiles}};
}

#  Widget database files
#
#  Usage: wdb($prjlist, $currprj, $shared_profile, \@wdblist)
sub wdb {
	my $this = $_[0];
	my $prjlist = $_[1];
	my $currprj = $_[2];
	my $shared_profile = $_[3];
	my $wdblist = $_[4];

	if($this->{active}) {
		# -- Make all paths absolute
		my @abslist = ();
		foreach my $path (@$wdblist) {
			push @abslist, File::Spec->catfile($currprj->getPath, $path);
		}
		# -- Store file list
		push @{$this->{wdbfiles}}, @abslist;
	}
	
	return 1;
}

return 1;
