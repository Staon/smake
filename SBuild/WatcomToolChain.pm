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

# Tool chain object of the Watcom compiler
package SBuild::WatcomToolChain;

use SBuild::ToolChain;

@ISA = qw(SBuild::ToolChain);

# Ctor
sub newToolChain {
	my $class = shift;
	my $this = SBuild::ToolChain->newToolChain;
	bless $this, $class;
}

# Get command to compile a C source file
#  Usage: getCCompile(\@targets, \@sources, $options)
#  Return: compilation string which can be run
sub getCCompiler {
	my $this = shift;
	my $targets = $_[0];
	my $sources = $_[1];
	my $options = $_[2];
	return "cc $options -c -o $targets->[0] @$sources";
}

# Get command to compile a C++ source file
#  Usage: getCPPCompile(\@targets, \@sources, $options)
#  Return: compilation string which can be run
sub getCXXCompiler {
	my $this = shift;
	my $targets = $_[0];
	my $sources = $_[1];
	my $options = $_[2];
	return "cc $options -c -o $targets->[0] @$sources";
}

#  Get command to link a binary
#
#  Usage: getLinker(\@targets, \@sources, $options, \%args)
sub getLinker {
	my $this = $_[0];
	my $targets = $_[1];
	my $sources = $_[2];
	my $options = $_[3];
	my $args = $_[4];
	
	# -- size of the stack
	my $stacksize = $args->{'stacksize'};
	if(defined($stacksize)) {
		$stacksize = "-N$stacksize";
	}
	else {
		$stacksize = "";
	}
	
	return "cc $options $stacksize -o $targets->[0] @$sources";
} 

#  Get command to create a library
#
#  Usage: getLibArchiver(\@targets, \@sources, $options, \%args)
sub getLibArchiver {
	my $this = $_[0];
	my $targets = $_[1];
	my $sources = $_[2];
	my $options = $_[3];
	my $args = $_[4];

	# -- page boundary
	my $pagesize = $args->{pagesize};
	if(defined($pagesize)) {
		$pagesize = "-p=$pagesize";
	}
	else {
		$pagesize = "";
	}
	# -- remove .lib from the name of the library
	my $libname = $targets->[0];
#	$libname =~ s/[.]lib$//;
	return "wlib $options $pagesize $libname @$sources";
}

#  Get command to clean
#
#  Usage: getClean(\@files, $options [, $clean_files])
sub getClean {
	my $this = $_[0];
	my $files = $_[1];
	my $options = $_[2];
	my $clean_files = $_[3];
	$clean_files = "" if(! defined($clean_files));
	
	return "rm $options -f @$files $clean_files";
}

#  Get command to clean
#
#  Usage: getRename($source, $target)
sub getRename {
	my $this = $_[0];
	my $source = $_[1];
	my $target = $_[2];
	
	return "mv $source $target";
}

#  Get extension of object files
sub getObjectExtension {
	return ".o";
}

#  Get extension of executable files
sub getExecExtension {
	return "";
}

#  Get extension of libraries
sub getLibExtension {
	return ".lib";
}

#  Create library linking option
#
#  Usage: getLibOption($libname)
sub getLibOption {
	my $this = $_[0];
	my $libname = $_[1];
	
	return "-l$libname"
}

#  Get linking option of a library which is linked every time. Including the
#  case when no symbol is used.
#
#  Usage: getForceLibOption($libpath)
sub getForceLibOption {
	my $this = $_[0];
	my $libpath = $_[1];
	
	return "\"-Wl DISABLE 1038 FILE $libpath\"";
}

#  Create library directory option
#
#  Usage: getLibDirOption($libdir)
sub getLibDirOption {
	my $libdir = $_[1];
	return "-L$libdir";
}

#  Create include directory option
#
#  Usage: getLibDirOption($incdir)
sub getIncDirOption {
	my $incdir = $_[1];
	return "-I$incdir";
}

#  Create an option to switch on C++ exceptions
sub getExceptionOption {
	return "'-WC -xst'";
}

return 1;
 
