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

use SMakeGen::Typograph;
use SMakeGen::GenFactory;

#  Usage: printUsage($exitval)
sub printUsage {
	print "Usage: sgen type arguments...\n";
	print "\n";
	print "Options:\n";
	print "  -h      --help           Print this message and stop.\n";
	print "\n";
	print "Supported types:\n";
	print "  lib project_name library_name\n";
	print "        It creates a library project with name 'project_name'. Compiled\n";
	print "        library has name 'library_name'. Don't specify a library suffix!\n";
	print "\n";
	print "  exec project_name bin_name\n";
	print "        It creates a executable project with name 'project_name'. Compiled\n";
	print "        binary file has name 'bin_name'. Don's specify a suffix!\n";
	print "\n";
	print "  test bin_name test_type\n";
	print "        It creates a test executable 'bin_name'. Don't specify a suffix!\n";
	print "        The type argument can be one of these values:\n";
	print "                r ..... cProces\n";
	print "                p ..... cPhotonProces\n";
	print "                s ..... cSocketProces\n";
	print "\n";
	print "  root [incdir]\n";
	print "        It creates a root project definition. When you specify the incdir\n";
	print "        argument the HeaderDir directive is written into the SMakefile.\n";
	
	exit $_[0];
}

my $help = '';
if(! GetOptions('help' => \$help)) {
	printUsage(-1);
}
if($help) {
	printUsage(0);
}

my $prjname = shift @ARGV;
my $factory = SMakeGen::GenFactory->newGenFactory;
my $generator = $factory->getGenerator($prjname, @ARGV);
if(defined($generator)) {
	my $list = $generator->createDirectives();
	my $typo = SMakeGen::Typograph->newTypograph(78);
	$_->generateDirective($typo) foreach (@$list);
}

exit 0;
