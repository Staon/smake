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

use SMakeParser::Parser;
use SMakeParser::Worker;

#  Usage: printUsage($exitval)
sub printUsage {
	print "Usage: smake [options] stages...\n";
	print "\n";
	print "Options:\n";
	print "  -h       --help           Print this message and stop.\n";
	print "  -b dir   --base=dir       Change starting directory.\n";
	print "  -s       --search         Do recursive searching of SMakefiles.\n";
	print "  -f       --force          Don't stop work when a project fails.\n";
	print "  -p name  --profile=name   Use a compilation profile.\n";
	print "  -l lib   --libsearch=lib  Find projects which link project 'lib'.\n";
	print "  -c       --checkrep       Check consistency of the repository and your\n";
	print "                            project.\n";
	print "  -d       --duplicate      Duplicate installed files instead of linking.\n";
	print "  -i path  --install=path   Specify root of installation of the runtime.\n";
	print "  -g file  --globalcfg=file Specify global configuration file.\n";
	print "  -v lev   --verbosity=lev  Change logging verbosity. 0 means no logging, 5 is\n";
	print "                            the highest value. Default value is 3.\n";
	print "  -r prj   --restrict=prj   Restrict roots of stage dependencies to projects\n";
	print "                            which match the regular expression 'prj'.\n";
	print "  -x file  --xml=file       Store report of smake run into the XML file 'file'.\n";
	print "  -a       --astra          Use the Astra checker to detect errors in\n";
	print "                            SMakefiles.\n";
	print "  -m       --memory         Use a mode which makes the memory footprint low. The\n";
	print "                            smake stores parsed projects into files at\n";
	print "                            /tmp/smakecache/ and keeps only limited subset\n";
	print "                            of projects in the memory.\n";
	print "  -e spell --enchant=spell  Change a library to a named profile (some kind\n";
	print "                            of magic :)). The 'spell' must be in the format\n";
	print "                            'libname->profile_name'. The utility will go\n";
	print "                            through all SMakefiles in its scope (see the -s\n";
	print "                            for the whole development tree) and it'll generate\n";
	print "                            a shell script at its standard output which must\n";
	print "                            be run to perform the spell. The script adds\n";
	print "                            the named profile to all projects which links\n";
	print "                            the library. However, the library is not removed\n";
	print "                            from the list of linked libraries.\n";
	
	exit $_[0];
}

# Set autoflush behavior
local $| = 1;

# Parse command line options
my $search = '';
my $help = '';
my $force = '';
my $verbosity = 3;
my @compile_profiles = ();
my $libsearch = '';
my $checkrepository = 0;
my $base = '';
my $duplicate = 0;
my $install = '';
my $config_file = '';
my $restrict = undef;
my $xmlfile = undef;
my $astrachecker = 0;
my $memory = 0;
my $enchantlibrary = '';
if(! GetOptions('search' => \$search,
                'force' => \$force,
                'profile=s' => \@compile_profiles,
                'verbosity=i' => \$verbosity,
                'libsearch=s' => \$libsearch,
                'checkrep' => \$checkrepository,
                'base=s' => \$base,
                'duplicate' => \$duplicate,
                'install=s' => \$install,
                'globalcfg=s' => \$config_file,
                'restrict=s' => \$restrict,
                'xml=s' => \$xmlfile,
                'astra' => \$astrachecker,
                'memory' => \$memory,
                'enchant=s' => \$enchantlibrary,
                'help' => \$help)) {
	printUsage(-1);
}
if($help) {
	printUsage(0);
}

# -- Don't run the utility as the root
if($> == 0 || $) == 0) {
	die "Don't run the utility with effective rights of the superuser or his group!";
}

# -- Change base dir
if($base) {
	chdir $base or die "It's not possible to change current directory to '$base'!";
}

# Parse stage list
my @stages = @ARGV;
# Default value when no stage is specified
@stages = ('all') if(! @stages);

# Stage aliases
my %stage_alias = (
		'all' => ['libinst', 'binpostlink'],
		'new' => ['clean', 'libinst', 'binpostlink'],
		'lib' => ['libinst'],
		'bin' => ['binpostlink'],
		'example' => ['expostlink'] 
);
my @srcstages = @stages;
@stages = ();
foreach my $stage (@srcstages) {
	my $repl = $stage_alias{$stage};
	if(defined($repl)) {
		push @stages, @$repl;
	}
	else {
		push @stages, $stage;
	}
}

# -- Check whether stages reg and unreg are specified alone
my $dont_check_project_validity = 0;
if(grep { $_ eq "reg" || $_ eq "unreg" } @srcstages) {
	if(@srcstages > 1) {
		print "Stages 'reg' and 'unreg' must be specified alone without another stage!\n";
		die;
	}
	$dont_check_project_validity = 1;
}

# -- Global parser entry point
local $SMakeParser = SMakeParser::Parser->newParser(\@stages);

# -- Create the worker
my $worker = SMakeParser::Worker->newWorker($verbosity, $xmlfile);

# -- Process the task
$worker->readRepository or exit(1);
$worker->checkRepository($checkrepository); #or exit(1);
$worker->readConfigurationFiles($config_file) or exit(1);
$worker->initEnvironment(\@compile_profiles, undef, $duplicate, $install) or exit(1);
$worker->createRunner($SMakeParser, $libsearch, $checkrepository, $astrachecker, $enchantlibrary);
$worker->readFiles($SMakeParser, $search, $dont_check_project_validity, $memory) or exit(1);
$worker->runStages(\@stages, $force, $restrict) or exit(1);
$worker->storeRepository() or exit(1);

exit(0);
