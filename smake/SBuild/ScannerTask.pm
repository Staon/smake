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

#  A task which scans a source file and compute dependencies
package SBuild::ScannerTask;

use SBuild::Task;

@ISA = qw(SBuild::Task);

use File::Basename;
use File::Path;

#  Ctor
#
#  Usage: newTask($name, $resource, $scanner, $srcfile, $depfile)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{scanner} = $_[3];
	$this->{srcfile} = $_[4];
	$this->{depfile} = $_[5];
	bless $this, $class;
} 

# Default empty running method
#   Usage: processTask(profile, reporter, $project)
#   Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];
	
	my $depfile = $this->{depfile};
	my $srcfile = $this->{srcfile};
	
	# -- create directory
	my $dir = $depfile->getDirectory($profile);
	if($dir ne '') {
		my $err;
		mkpath($dir, { error => $err });
		foreach my $diag (@$err) {
			my ($file, $message) = each %$diag;
			$reporter->reportError("A directory cannot be created: $message");
			return 0;
		}
	}
	
	# -- create scanner 
	my $scanner = $profile->getScannerList->getScanner($this->{scanner});
	if(! defined($scanner)) {
		$reporter->reportError("Scanner " . $this->{scanner} . " is not known!");
		return 0;
	}
	
	# -- scan the source file
	my $list = $scanner->scanFile($profile, $reporter, $srcfile->getFullname($profile));
	if(! open(DEPFILE, ">" . $depfile->getFullname($profile))) {
		$reporter->reportError("It's not possible to open file $depfile for writing.");
		return 0;
	}
	print DEPFILE "$_\n" foreach (@$list);
	close(DEPFILE);
	
	return 1;
}

#  Decide if the task should be run
#
#  Usage: shallBeRun($profile, $reporter, $project)
#  Return: True when the project shall be run
sub shallBeRun {
	my $this = $_[0];
	my $profile= $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $srcfile = $this->{srcfile};
	my $depfile = $this->{depfile};
	
	# -- check source file
	my $decider = $profile->getDecider;
	return 1 
		if($decider->isOutOfTime([$depfile->getFullname($profile)], 
		                         [$srcfile->getFullname($profile)]));
	
	# -- read dependency file
	my @list = ();
	open(DEPFILE, "<" . $depfile->getFullname($profile));
	@list = <DEPFILE>;
	close(DEPFILE);
	chomp(@list);

	# -- check header files
	return 1 if($decider->isOutOfTime([$depfile->getFullname($profile)], \@list));
	
	return 0;
}

return 1;
