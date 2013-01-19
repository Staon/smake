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

#  Source scanner based on C/C++ preprocessor
package SMakeParser::CppScanner;

use SBuild::Scanner;

@ISA = qw(SBuild::Scanner);

use QNX4;

#  Ctor
sub newScanner {
	my $class = $_[0];
	my $this = SBuild::Scanner->newScanner;
	bless $this, $class;
}

#  Scan a source file for dependencies
#
#  Usage: scanFile($profile, $reporter, $file)
sub scanFile {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $file = $_[3];
	
	# -- construct scanner's command
	my $options = $this->getOptions($profile);
	my $command = "gcc $options -E $file 2>/dev/null | egrep '^# [[:digit:]]+ \".+\" 1' | sed 's/^[^\"]*\"// ; s/\".*\$//' | sort -u";
	
	# -- report the command
	$reporter->taskCommand('', $command);
	
	# -- run the command to get list of dependency files
	my @list = split(/\s+/, QNX4::backticks($command));
	# -- trim end lines
	map { s/\n$// =~ $_ } @list;
	
	return \@list;
}

#  Get options of the preprocessor
#
#  Usage: getOptions($profile)
#  Return: $options
sub getOptions {
	die "It's not possible to invoke a pure virtual method CppScanner::getOptions!";
}

return 1;
