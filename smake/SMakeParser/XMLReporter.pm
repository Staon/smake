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

#  XML reporter - the reporter creates an XML file with reported errors
package SMakeParser::XMLReporter;

use SBuild::Reporter;

@ISA = qw(SBuild::Reporter);

use IO::File;
use File::Basename;
use File::Spec;

#  Ctor
#
#  Usage newReporter($filename)
sub newReporter {
	my ($class, $filename) = @_;
	my $this = SBuild::Reporter->newReporter;
	$this->{filename} = $filename;
	$this->{file} = new IO::File "> $filename";
	if(! defined($this->{file})) {
		die "It's not possible to create file '" . $filename . "'!";
	}
	$this->{indent} = 0;
	$this->{begin} = 1;
	bless $this, $class;
	
	# Write XML header and the root tag
	print {$this->{file}} "<?xml version=\"1.0\"?>\n\n";
	$this->writeBeginTag("smake_report");

	return $this;
}

sub DESTROY {
	my $this = $_[0];
	
	# -- finish the report file
	$this->writeEndTag("smake_report");
	$this->{file}->close;
	
	# -- create reports with packed XSLT transformation
	my $directory = dirname($this->{filename});
	my $basename = basename($this->{filename});
	local *DIRHANDLE;
	if(! opendir(DIRHANDLE, $directory)) {
		die "Cannot read content of the directory $directory!";
	}
	my @files = grep { /[.]sxsl$/ } readdir(DIRHANDLE);
	closedir(DIRHANDLE);
	foreach my $xsltfile (@files) {
		my $suffix = $basename;
		$suffix =~ s/^.*[.]//;
		my $name = $basename;
		$name =~ s/[.][^.]*$//;
		my $xsltname = $xsltfile;
		$xsltname =~ s/[.][^.]*$//;
		my $output = File::Spec->catfile(
			$directory, $name . "_" . $xsltname . "." . $suffix);

		$this->packXSLT($output, $this->{filename}, File::Spec->catfile($directory, $xsltfile));		
	}
}

# Pack an XSLT transformation into specified XML file
#
# Usage: packXSLT($packedfile, $xmlfile, $xsltfile)
sub packXSLT {
	my ($this, $packedfile, $xmlfile, $xsltfile) = @_;
	my $file = new IO::File "> $packedfile";
	if(! defined($file)) {
		die "It's not possible to create packed report file " . $packedfile . "!";
	}

	# -- print header of the packed file
	print $file "<?xml version=\"1.0\"?>\n";
	print $file "<?xml-stylesheet type=\"text/xml\" href=\"#stylesheet\"?>\n";
	print $file "\n";
	print $file "<!DOCTYPE doc [\n";
	print $file "<!ATTLIST xsl:stylesheet\n";
  	print $file "  id ID #REQUIRED>\n";
	print $file "]>\n";
	print $file "\n";
	print $file "<doc>\n";

	# -- copy the transformation
	my $xslt = new IO::File "< $xsltfile";
	if(! defined($xslt)) {
		die "Cannot open XSLT transformation file " . $xsltfile;
	}
	while(my $line = <$xslt>) {
		print $file "  ";
		print $file $line;
	}
	$xslt->close;
	
	# -- copy content of the XML file
	my $xml = new IO::File "< $xmlfile";
	if(! defined($xml)) {
		die "Cannot open the report file " . $xmlfile;
	}
	while(my $line = <$xml>) {
		if($line !~ /^\<\?xml/) {
			print $file "  ";
			print $file $line
		}
	}
	$xml->close;

	# -- finish the packed file
	print $file "</doc>\n";	
	$file->close;
}

sub printIndent {
	my ($this, $level) = @_;
	print {$this->{file}} ' ' x ($level * 2);
}

sub writeBeginTag {
	my $this = $_[0];
	my $tag = $_[1];

	# -- indentation	
	if(! $this->{begin}) {
		print {$this->{file}} "\n";
	}
	$this->printIndent($this->{indent});
	++ $this->{indent};

	# -- the tag
	print {$this->{file}} "<${tag}>";
	
	# -- change the indentation state
	$this->{begin} = 0;
}

sub writeEndTag {
	my $this = $_[0];
	my $tag = $_[1];
	
	# -- indentation
	-- $this->{indent};
	if($this->{begin}) {
		$this->printIndent($this->{indent});
	}

	# -- the tag	
	print {$this->{file}} "</${tag}>\n";
	
	# -- change level, state
	$this->{begin} = 1;
}

sub map_XML_characters {
	my $char = $_[0];
	
	if($char eq "&") {
		$char = "&amp;";
	}
	elsif($char eq "<") {
		$char = "&lt;";
	}
	elsif($char eq ">") {
		$char = "&gt;";
	}
	elsif($char eq "\"") {
		$char = "&quot;";
	}
	elsif($char eq "'") {
		$char = "&apos;";
	}
	elsif(
		((ord($char) >= 1) && (ord($char) <= 0x1f)) ||
		(ord($char) >= 0x7f)) {
		$char = "_";
	}
	
	return $char;
}

sub writeText {
	my $this = $_[0];
	my $text = $_[1];
	
	my @chars = split("", $text);
	$text = join("", map { map_XML_characters $_; } @chars);
	print {$this->{file}} $text;
}

# Usage: reportError($type, $message)
sub writeError {
	my $this = $_[0];
	my $type = $_[1];
	my $message = $_[2];
	
	# -- begin the main tag
	$this->writeBeginTag($type);
	
	# write project name if it's set
	if(defined($this->{project_name})) {
		$this->writeBeginTag("project");
		$this->writeText($this->{project_name});
		$this->writeEndTag("project");
		$this->writeBeginTag("path");
		$this->writeText($this->{project_path});
		$this->writeEndTag("path");
	}
	
	# write command it it's set
	if(defined($this->{command})) {
		$this->writeBeginTag("command");
		$this->writeText($this->{command});
		$this->writeEndTag("command");
	}
	
	# write the message
	my @msgs = split(/\n/, $message);
	$this->writeBeginTag("message");
	foreach my $msg (@msgs) {
		$this->writeBeginTag("line");
		$this->writeText($msg);
		$this->writeEndTag("line");
	}
	$this->writeEndTag("message");
	
	$this->writeEndTag($type);
	print "\n";
}

#  Report beginning of compilation
sub reportStartOfCompilation {
	SBuild::Reporter::reportStartOfCompilation(@_);
}

#  It's called when compilation ends
sub reportEndOfCompilation {
	SBuild::Reporter::reportEndOfCompilation(@_);
	
	# -- print time of compilation
	my $this = $_[0];
	$this->writeBeginTag("report");
	
	$this->writeBeginTag("begin");
	$this->writeText($this->printDate($this->getCompilationBeginning));
	$this->writeEndTag("begin");

	$this->writeBeginTag("end");
	$this->writeText($this->printDate($this->getCompilationEnding));
	$this->writeEndTag("end");
	
	$this->writeBeginTag("time");
	$this->writeText($this->printInterval($this->getCompilationTime));
	$this->writeEndTag("time");
	
	$this->writeEndTag("report");
	print "\n";
}

# Report entering of a task
#   usage: enterTask(task_name)
sub enterTask {

}

# Report leaving of a task
#   Usage: leaveTask(task_name)
sub leaveTask {
	my $this = $_[0];
	delete $this->{command};
}

#  Report a broken project (previous stage failed)
#
#  Usage: reportBrokenProject($prjname, $prjpath, $stage)
sub brokenProject {

}

# Report a task command
#   Usage: taskCommand(task_name, command)
sub taskCommand {
	my $this = $_[0];
	$this->{command} = $_[2];
}

# Report a task result
#   Usage: taskResult(task_name, result_flag, result_string)
sub taskResult {
	my $this = $_[0];
	my $task_name = $_[1];
	my $result_flag = $_[2];
	my $result_string = $_[3];
	
	if(! $result_flag) {
		$this->writeError("error", $result_string);
	}
	else {
		if(! $result_string =~ /^\s*$/) {
			$this->writeError("taskmsg", $result_string);
		}
	}
}

#  Report entering of a stage
#
#  Usage: enterStage($stage_name)
sub enterStage {

}

#  Report leaving of a stage
#
#  Usage: leaveStage($stage_name)
sub leaveStage {

}

#  Report an error
#
#  Usage: reportError($message)
sub reportError {
	my $this = $_[0];
	my $message = $_[1];

	$this->writeError("error", $message);
}

#  Report and warning
#
#  Usage: reportWarning($message)
sub reportWarning {
	my $this = $_[0];
	my $message = $_[1];
	
	$this->writeError("warning", $message);
}

#  Report entering of a project
#
#  Usage: enterProject($projectname, $projectpath)
sub enterProject {
	my $this = $_[0];
	$this->{'project_name'} = $_[1];
	$this->{'project_path'} = $_[2];
}

#  Report leaving of a project
#
#  Usage: leaveProject($projectname, $projectpath)
sub leaveProject {
	my $this = $_[0];
	delete $this->{'project_name'};
	delete $this->{'project_path'};
}

#  Report reading of a repository file
#
#  Usage: reportRepository($repfile)
sub reportRepository {

}

#  Report an installation task
#
#  Usage: reportInstall($message)
sub reportInstall {
	my $this = $_[0];
	my $message = $_[1];

	# TODO: write installation log
}

#  Report an uninstallation task
#
#  Usage: reportUninstall($message)
sub reportUninstall {

}

#  Report a cycle in the graph of dependencies of projects
#
#  Usage: reportProjectCycle($prjlist)
sub reportProjectCycle {
	my $this = $_[0];
	my $prjlist = $_[1];

	my $message = "Stage dependencies are cycled: @$prjlist";
	$this->writeError("error", $message);
}

#  Report beginning of parsing of a SMakefile of a project
#
#  Usage: reportProjectParsing($prjname, $prjpath)
sub reportProjectParsing {
	my $this = $_[0];
	$this->{'project_name'} = $_[1];
	$this->{'project_path'} = $_[2];
}

#  Report end of parsing of a project
#
#  Usage: reportEndOfParsing($prjname, $prjpath)
sub reportEndOfParsing {
	my $this = $_[0];
	delete $this->{'project_name'};
	delete $this->{'project_path'};
}

#  Begin checking of a repository
#
#  Usage: reportRepositoryBegin($repository)
sub reportRepositoryBegin {

}

#  Usage: reportRepositoryProjectStatus($repository, $project, $okflag)
sub reportRepositoryProjectStatus {

}

#  Usage: reportRepositoryProjectUnreg($project)
sub reportRepositoryProjectUnreg {

}

#  Usage: reportRepositoryEnd($repository)
sub reportRepositoryEnd {

}

sub projectCheckBegin {

}

#  Checking of a project
#
#  Usage: reportProjectRepositoryStatus($project, $path, $okflag)
sub projectRepositoryStatus {

}

sub projectCheckEnd {

}

return 1;
