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

#  Library main resource
package SMakeParser::LibResource;

use SMakeParser::MainResource;

@ISA = qw(SMakeParser::MainResource);

use SBuild::LibTask;
use SBuild::LibInstTask;
use SBuild::TargetResource;

#  Ctor
#
#  Usage: newResource($libname, $private, \%args)
sub newResource {
	my $class = $_[0];
	my $this = SMakeParser::MainResource->newResource($_[1]);
	$this->{private} = $_[2];
	$this->setArguments($_[3]);
	bless $this, $class;
}

#  Extend resource map
#
#  Usage: extendMap($map, $assembler, $profile, $reporter)
sub extendMap {
	return 1;
}

#  Process the main resource
#
#  Usage: processResource($map, $assembler, $profile, $reporter)
sub processResource {
	my $this = $_[0];
	my $map = $_[1];
	my $assembler = $_[2];
	my $profile = $_[3];
	my $reporter = $_[4];
	
	my $objfiles = $assembler->getObjectFiles;
	
	# -- library linking task
	my $libtask = SBuild::LibTask->newTask(
						$this->getFilename, $this, 
						[$this], $objfiles, [], 
						$this->getArguments);
	$assembler->appendTask("link", $libtask);

	if(! $this->{private}) {
		# -- create installation task
		my $insttask = SBuild::LibInstTask->newTask(
						"inst:" . $this->getFilename, $this, 
						$this->getFilename, $this);
		$assembler->appendRawTask("libinst", $insttask);
	}
	
	# -- library clean task
	$assembler->addClean($this);
	# -- Watcom specific file
	$assembler->addClean(SBuild::TargetResource->newResource($this->getPurename . ".lst"));
	
	return $libtask;
} 

return 1;
