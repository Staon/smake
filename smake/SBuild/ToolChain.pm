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

#  Generic ToolChain object
package SBuild::ToolChain;

# Ctor
sub newToolChain {
	my $class = shift;
	my $this = {};
	bless $this, $class;
}

# Get command to compile a C source file
#  Usage: getCCompile(\@targets, \@sources, $options)
#  Return: compilation string which can be run
sub getCCompiler {
	die "Pure virtual method ToolChain::getCCompiler cannot be invoked!\n";
}

# Get command to compile a C++ source file
#  Usage: getCPPCompile(\@targets, \@sources, $options)
#  Return: compilation string which can be run
sub getCXXCompiler {
	die "Pure virtual method ToolChain::getCXXCompiler cannot be invoked!\n";
}

#  Get command to link a binary
#
#  Usage: getLinker(\@targets, \@sources, $options)
sub getLinker {
	die "Pure virtual method ToolChain::getLinker cannot be invoked!\n";
} 

#  Get command to create a library
#
#  Usage: getLibArchiver(\@targets, \@sources, $options, \%args)
sub getLibArchiver {
	die "Pure virtual method ToolChain::getLibArchiver cannot be invoked!\n";
}

#  Get command to clean
#
#  Usage: getClean(\@files, $options [, $clean_files])
sub getClean {
	die "Pure virtual method ToolChain::getClean cannot be invoked!\n";
}

#  Get command to clean
#
#  Usage: getRename($source, $target)
sub getRename {
	die "Pure virtual method ToolChain::getRename cannot be invoked!\n";
}

#  Get extension of object files
sub getObjectExtension {
	die "Pure virtual method ToolChain::getObjectExtension cannot be invoked!\n";
}

#  Get extension of executable files
sub getExecExtension {
	die "Pure virtual method ToolChain::getExecExtension cannot be invoked!\n";
}

#  Get extension of libraries
sub getLibExtension {
	die "Pure virtual method ToolChain::getLibExtension cannot be invoked!\n";
}

#  Create library linking option
#
#  Usage: getLibOption($libname)
sub getLibOption {
	die "Pure virtual method ToolChain::getLibOption cannot be invoked!\n";
}

#  Get linking option of a library which is linked every time. Including the
#  case when no symbol is used.
#
#  Usage: getForceLibOption($libname)
sub getForceLibOption {
	die "Pure virtual method ToolChain::getForceLibOption cannot be invoked!\n";
}

#  Create library directory option
#
#  Usage: getLibDirOption($libdir)
sub getLibDirOption {
	die "Pure virtual method ToolChain::getLibDirOption cannot be invoked!\n";
}

#  Create include directory option
#
#  Usage: getLibDirOption($incdir)
sub getIncDirOption {
	die "Pure virtual method ToolChain::getIncDirOption cannot be invoked!\n";
}

#  Create an option to switch on C++ exceptions
sub getExceptionOption {
	die "Pure virtual method ToolChain::getExceptionOption cannot be invoked!\n";
}

#  Get compiler option for turning on of debugging information
#
#  Usage getDbugOption($tool, $level)
#    tool ... name of tool (c, cxx, link)
#    level .. debug level
sub getDebugOption {
	die "Pure virtual method ToolChain::getDebugOption"
}

return 1;
