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

# Resolver record of C source files
package SMakeParser::CRecord;

use SMakeParser::CompileRecord;

@ISA = qw(SMakeParser::CompileRecord);

use SBuild::CCompileTask;

#  Ctor
#
#  Usage: newRecord([mask [, $prefix, $postfix]])
sub newRecord {
	my $class = $_[0];
	my $mask = $_[1];
	$mask = '[.]c$' if(! defined($mask));
	my $this = SMakeParser::CompileRecord->newRecord($mask, $_[2], $_[3]);
	bless $this, $class;
}

#  Get name of a source scanner
sub getScanner {
	return "cscanner";
}

#  Create compilation task
#
#  Usage: getCompilationTask($srcfile, $objectfile, \@deps)
sub getCompilationTask {
	my $this = $_[0];
	my $srcfile = $_[1];
	my $objectfile = $_[2];
	my $deps = $_[3];
	
	#   Usage: newTask($name, \@target, \@source, \@deps)
	return SBuild::CCompileTask->newTask(
						$srcfile->getFilename, $srcfile,
						[$objectfile], [$srcfile], $deps);
}

return 1;
