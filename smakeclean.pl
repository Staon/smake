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

use Getopt::Long;

use SBuild::Repository;
use SBuild::Profile;
use SBuild::InstallLogger;
use SMakeParser::StandardReporter;
use File::Spec;

#  Usage: printUsage($exitval)
sub printUsage {
	print "Usage: smakeclean [options]\n";
	print "\n";
	print "Options:\n";
	print "  -h      --help           Print this message and stop.\n";
	print "  -v lev  --verbosity=lev  Change logging verbosity. 0 means no logging, 5 is\n";
	print "                           the highest value. Default value is 3.\n";
	print "\n";
	
	exit $_[0];
}

# Set autoflush behavior
local $| = 1;

# Parse command line options
my $help ='';
my $verbosity = 3;
if(! GetOptions('verbosity=i' => \$verbosity,
                'help' => \$help)) {
	printUsage(-1);
}
if($help) {
	printUsage(0);
}

# -- create a reporter
my $reporter = SMakeParser::StandardReporter->newReporter($verbosity);

# -- Read project repository
my $repository = SBuild::Repository->newRepository;
$repository->initializeRepository($reporter) or die("It's not possible to open repository!");

# -- Create running profile
my $profile = SBuild::Profile->newProfile(undef, undef, undef, undef, $repository, undef);

# -- Read all log files 
my $logpath = $repository->getLogDirectory;

# -- list the source directory
opendir(DIRHANDLE, $logpath) or die("It's not possible to open directory $logpath");
my @files = grep { /[.]log$/ } readdir(DIRHANDLE);
closedir(DIRHANDLE);

# -- Find all logs which are not part of an existing project. Then
#    clean all project's files and remove the project from the
#    repository.
my $ok_flag = 1;
foreach my $logfile (@files) {
	my $install_log = SBuild::InstallLogger->newLoggerFile(File::Spec->catfile($logpath, $logfile));
	my $prjpath = $install_log->getProjectPath;
	my $smakefile = File::Spec->catfile($prjpath, "SMakefile");
	if(! -f $smakefile) {
		$reporter->enterProject($prjpath, $prjpath);
		$reporter->enterStage("project_clean");

		# -- clean installed files		
		$reporter->enterTask("log_processing");
		$install_log->cleanProject(undef, $profile, $reporter);
		$install_log->removeLog($profile, $reporter);
		$reporter->leaveTask("log_processing");
		
		$reporter->leaveStage("project_clean");
		$reporter->leaveProject($prjpath, $prjpath);
	}
}

# -- remove orphaned records in the repository
$repository->removeOrphans($reporter);

# -- store modified repository
$repository->storeRepository() or die "It's not possible to store the repository!";

exit 0;
