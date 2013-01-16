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

# OLog2 profiles
package SMakeParser::OLog2Profile;

use SBuild::CompileProfile;

@ISA= qw(SBuild::CompileProfile);

use SBuild::Option;
use SMakeParser::ProjectAssembler;

#  Usage: newCompileProfile($mode, other arguments)
sub newCompileProfile {
	my $class = shift;
	my $mode = shift;
	my $this = SBuild::CompileProfile->newCompileProfile("olog2" . $mode);
	$this->{mode} = $mode;
	$this->{arguments} = [@_];	
	bless $this, $class;
}

#  Get compilation options
#
#  Usage: getOptions($variable, $optionlist, $profile)
sub getOptions {
	my $this = $_[0];
	my $variable = $_[1];
	my $optionlist = $_[2];
	my $profile = $_[3];

	if($variable eq "CXXCPPFLAGS") {
		my $mode = $this->{"mode"};
		if($mode eq "disable") {
			$optionlist->removeOptions("olog2disable");
			$optionlist->removeOptions("olog2logger");
			$optionlist->removeOptions("olog2type");
			$optionlist->removeOptions("olog2level");
			$optionlist->removeOptions("olog2secret");
			$optionlist->appendOption(SBuild::Option->newOption("olog2disable", "-DONDRART_DISABLE_LOGGING"));
		}
		elsif($mode eq "logger") {
			$optionlist->removeOptions("olog2logger");
			foreach my $logger (@{$this->{arguments}}) {
				if($logger eq "file") {
					$optionlist->appendOption(SBuild::Option->newOption("olog2logger", "-DOLOG2_FILE_LOGGER"));
				}
				elsif($logger eq "console") {
					$optionlist->appendOption(SBuild::Option->newOption("olog2logger", "-DOLOG2_CONSOLE_LOGGER"));
				}
				elsif($logger eq "syslog") {
					$optionlist->appendOption(SBuild::Option->newOption("olog2logger", "-DOLOG2_SYSLOG_LOGGER"));
				}
				elsif($logger eq "logserv") {
					$optionlist->appendOption(SBuild::Option->newOption("olog2logger", "-DOLOG2_LOGSERV_LOGGER"));
				}
			}
		}
		elsif($mode eq "type") {
			$optionlist->removeOptions("olog2type");
			my %disabled = (
				"ONDRART_NO_CRITICAL" => 1,
				"ONDRART_NO_ERROR" => 1,
				"ONDRART_NO_WARNING" => 1,
				"ONDRART_NO_INFO" => 1,
				"ONDRART_NO_DEBUG" => 1);
			foreach my $type (@{$this->{arguments}}) {
				if($type eq "critical") {
					delete($disabled{"ONDRART_NO_CRITICAL"});
				}
				elsif($type eq "error") {
					delete($disabled{"ONDRART_NO_ERROR"});
				}
				elsif($type eq "warning") {
					delete($disabled{"ONDRART_NO_WARNING"});
				}
				elsif($type eq "info") {
					delete($disabled{"ONDRART_NO_INFO"});
				}
				elsif($type eq "debug") {
					delete($disabled{"ONDRART_NO_DEBUG"});
				}
			}
			foreach my $distype (keys(%disabled)) {
				$optionlist->appendOption(SBuild::Option->newOption("olog2type", "-D" . $distype));
			}
		}
		elsif($mode eq "level") {
			$optionlist->removeOptions("olog2level");
			$optionlist->appendOption(
				SBuild::Option->newOption(
					"olog2type", 
					"-DONDRART_NO_LEVEL=" . ($this->{arguments}->[0] + 1)));
		}
		elsif($mode eq "secret") {
			$optionlist->removeOptions("olog2secret");
			$optionlist->appendOption(SBuild::Option->newOption("olog2secret", "-DOLOG2_SECRET_SERVICE"));
		}
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

	# -- when the console logger is used, link ncurses and appropriate
	#    OndraRT libraries.
	my $mode = $this->{"mode"};
	if($mode eq "logger") {
		foreach my $logger (@{$this->{arguments}}) {
			if($logger eq "console") {
				$assembler->addLink("ondrart_term.lib");
				$assembler->addSysLink("ncurses3r.lib");
			}
			elsif($logger eq "logserv") {
				$assembler->addLink("logclient.lib");
			}
		}
	}
}

return 1;
