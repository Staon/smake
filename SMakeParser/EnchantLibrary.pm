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

#  A project query
#
#  This is not an specific query, but only a template to write your
#  own query. This is an ugly solution but I have no time to do
#  it better.
package SMakeParser::EnchantLibrary;

use SMakeParser::TargetRunner;

@ISA = qw(SMakeParser::TargetRunner);

use SBuild::ProjectList;
use File::Spec;

#  Ctor
#
#  Usage: newRunner($parser, $profile, $reporter, $spell)
sub newRunner {
	my $class = $_[0];
	my $this = SMakeParser::TargetRunner->newTargetRunner($_[1], $_[2], $_[3]);
	
	# -- decode the spell
	my $spell = $_[4];
	if($spell =~ /^(.+)->(.+)$/) {
		$this->{library} = $1;
		$this->{profilename} = $2;
	}
	else {
		die "Wrong library or profile name";
	}
	
	# -- initialize status variables
	$this->{prjactive} = 0;
	$this->{linkdirective} = 0;
	$this->{line} = -1;
	$this->{lastpath} = "";
	$this->{offset} = 0;
	
	bless $this, $class;
}

#  Create a new initialized instance of the runner
sub cloneRunner {
	my $this = shift;
	
	my $runner = SMakeParser::EnchantLibrary->newRunner(
					$this->{parser},
					$this->{profile},
					$this->{reporter},
					$this->{library} . "->" . $this->{profilename});
	$this->cloneInternalData($runner);
	
	$runner->{lastpath} = $this->{lastpath};
	$runner->{offset} = $this->{offset};
	return $runner;
}

#  begin a project
#
#  Usage: startProject($prjlist, $currprj)
sub startProject {
	my ($this, $prjlist, $currprj) = @_;

	$this->{prjactive} = 1;
	$this->{linkdirective} = 0;
	$this->{line} = -1;
	$this->{prjname} = $currprj -> getName;
	$this->{prjpath} = $currprj -> getPath;
}

#  Stop the project
#
#  Usage: endProject
sub endProject {
	my $this = $_[0];
	
	if($this->{prjactive} && $this->{linkdirective} && $this->{line} >= 0) {
		# -- When several changes occur in one file, the location
		#    must be moved farer
		if($this->{lastpath} eq $this->{prjpath}) {
			++ $this->{offset};
		}
		else {
			$this->{lastpath} = $this->{prjpath};
			$this->{offset} = 0;
		}
		
		my $smakefile = $this->{prjpath} . "/SMakefile";
		my $line = $this->{line} + $this->{offset};
		my $tmpfile = "/tmp/smake_enchant_temp_file";

		print "echo \"Enchant " . $smakefile . "\"\n";
		print "sed '" . $line . " s/^\\([[:space:]]*\\)/\\1Profile(\"" .
		      $this->{profilename} . "\");\\\n\\1/' " . $smakefile . 
		      " > " . $tmpfile . "\n";
		print "mv -f " . $tmpfile . " " . $smakefile . "\n";
	}

	$this->deactivate	
}

sub deactivate {
	my $this = $_[0];

	$this->{prjactive} = 0;
	$this->{linkdirective} = 0;
	$this->{line} = -1;
	delete $this->{prjname};
	delete $this->{prjpath};
}

#sub dumpCaller {
##   1.  # 0 1 2 3 4
##   2. ($package, $filename, $line, $subroutine, $hasargs,
##   3.
##   4. # 5 6 7 8 9 10
##   5. $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash)
##   6. = caller($i);
#
#	my $i = 1;
#	my @cinfo = caller($i);
#	while(@cinfo) {
#		print "Frame: @cinfo\n";
#		++ $i;
#		@cinfo = caller($i);
#	};
#}

# Usage: searchLine($funcname)
sub searchLine {
	my ($this, $funcname) = @_;
	
	my $i = 1;
	my @cinfo = caller($i);
	while(@cinfo) {
		my ($package, $filename, $line, $subroutine) = @cinfo;
		return $line if($funcname eq $subroutine);
		++ $i;
		@cinfo = caller($i);
	}
	return -1;
}

#  Profile
#
#  Usage: profile($prjlist, $currprj, $shared_profile, $name, ...)
sub profile {
	my ($this, $prjlist, $currprj, $shared_profile, $name) = @_;

	if($this->{prjactive} && $name eq $this->{profilename}) {
		$this->deactivate;
	}

	if($this->{prjactive} && $this->{line} < 0) {
		$this->{line} = $this->searchLine("SMakeParser::FileParser::Profile");
	}
	
	return 1;
}

#  Resolve link dependencies
#
#  Usage: link($prjlist, $currprj, $shared_profile, \@linkdeps)
sub link {
	my ($this, $prjlist, $currprj, $shared_profile, $linkdeps) = @_;

	if($this->{prjactive}) {
		if(grep {$_ eq $this->{library}} @$linkdeps) {
			$this->{linkdirective} = 1;
			if($this->{line} < 0) {
				$this->{line} = $this->searchLine("SMakeParser::FileParser::Link");
			}
		}
	}
	
	return 1;
}

#  Specification of subdirectories
#
#  Usage: subdirs($prjlist, $currprj, $shared_profile, \@subdirs)
sub subdirs {
	my $this = shift;
	return $this->parseSubdirs(@_);
}

return 1;
