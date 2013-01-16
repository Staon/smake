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

# Embedding of perl interpreter
package SMakeParser::PerlProfile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;
use ExtUtils::Embed;

#  Usage: newCompileProfile()
sub newCompileProfile {
	my $class = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("perl");
	bless $this, $class;
}

sub parsePerlOptions {
	my $this = $_[0];
	
	my $ccopts = ExtUtils::Embed::ccopts;
	my $ldopts = ExtUtils::Embed::ldopts(1);
	
	my @opts = split(/\s+/, $ccopts);
	push @opts, split(/\s+/, $ldopts);
	
	my @cppflags = ();
	my @cflags = ();
	my @ldflags = ();
	my @libs = ();
	foreach my $opt (@opts) {
		if($opt =~ /^\s*$/) {
			
		}
		elsif(($opt =~ /^-g/) || ($opt =~ /^-w/)) {
			# -- do nothing, don't get debug flags
		}
		elsif($opt =~ /^-l/ ) {
			# -- a library
			$opt =~ s/^-l//;
			$opt =~ s/^perl$/libperl3r.lib/;
			push @libs, $opt;
		}
		elsif($opt =~ /^-L/ ) {
			# -- a library directory
			push @ldflags, $opt;
		}
		elsif($opt =~ /^-I/ ) {
			# -- include paths
			push @cppflags, $opt;
		}
		elsif($opt =~ /^-W[cC]/ ) {
			# -- compiler's option
			push @cflags, $opt;
		}
		elsif($opt =~ /^-Wl/ ) {
			# -- linker option
			push @ldflags, $opt;
		}
		elsif($opt =~ /^-/ ) {
			# -- all other options are handled as a compiler option
			push @cflags, $opt;
		}
		else {
			# -- arguments without options are handled as libraries
			push @libs, $opt;
		}
	}
	
	return (\@cppflags, \@cflags, \@ldflags, \@libs);
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];
	
	if(($variable eq "CPPFLAGS") or ($variable eq "CXXCPPFLAGS")) {
		my ($cppflags, $cflags, $ldflags, $libs) = $this->parsePerlOptions;
		$optionlist->appendOption(SBuild::Option->newOption("perl", "@$cppflags"));
	}
	if(($variable eq "CFLAGS") or ($variable eq "CXXFLAGS")) {
		my ($cppflags, $cflags, $ldflags, $libs) = $this->parsePerlOptions;
		$optionlist->appendOption(SBuild::Option->newOption("perl", "@$cflags"));
	}	
	if($variable eq "LDFLAGS") {
		my ($cppflags, $cflags, $ldflags, $libs) = $this->parsePerlOptions;
		$optionlist->appendOption(SBuild::Option->newOption("perl", "@$ldflags"));
	}
}

#  Modify current project structure
#
#  Usage: changeProject($map, $assembler, $profile)
sub changeProject {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];

	my ($cppflags, $cflags, $ldflags, $libs) = $this->parsePerlOptions;
	$assembler->addSysLink($libs);
}

return 1;
