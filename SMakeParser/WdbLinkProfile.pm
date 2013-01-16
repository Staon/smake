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

#  Wdb link profile - list of project which offers Wdb files to link
package SMakeParser::WdbLinkProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;
use SMakeParser::WdbRunner;
use SBuild::ProjectListEmpty;

#  Ctor
#
#  Usage: newCompileProfile(\@wdblist)
sub newCompileProfile {
	my $class = $_[0];
	my $this = SBuild::CompileProfile->newCompileProfile("wdblink");
	$this->{wdblist} = $_[1];
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile, $reporter)
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	if($variable eq "WDB_FILES") {
		my $wdblist = $this->{wdblist};
		my @filelist = ();
		foreach my $prj (@$wdblist) {
			my $prjpath = $profile->getRepository->getProjectPath($prj);
			if($prjpath) {
				#  create lib runner
				my $runner = SMakeParser::WdbRunner->newWdbRunner(
			                    $::SMakeParser, $profile, $reporter, $prj);
				# create own project list
				my $seplist = SBuild::ProjectListEmpty->newProjectList;
				# parse project's SMakefile
				return 0 if (! $runner->parseSMakefile($prjpath, $runner, $seplist));
			
				# store linked libraries
				push @filelist, $runner->getWdbList;
			}
		}
		my $value = join(' ', @filelist);
		$optionlist->appendOption(SBuild::Option->newOption("wdblink", $value));
	}
}

return 1;
