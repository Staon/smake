# Copyright (C) 2014 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is a free software: you can redistribute it and/or modify
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

# Header scanner of C/C++ sources
package SMake::ToolChain::Scanner::HdrScanner;

use SMake::ToolChain::Scanner::Scanner;

@ISA = qw(SMake::ToolChain::Scanner::Scanner);

use SMake::ToolChain::Constructor::Constructor;
use SMake::Data::Path;
use SMake::Model::Const;
use SMake::Utils::Utils;

# Create new header scanner
#
# Usage: new($tasktype, $restype, $resname, $instmodule)
#    tasktype .... a regular expression which describes type of the task
#    restype ..... a regular expression which describes type of the resource
#    resname ..... a regular expression which describes name of the resource
#    instmodule .. installation module name
sub new {
  my ($class, $tasktype, $restype, $resname, $instmodule) = @_;
  my $this = bless(SMake::ToolChain::Scanner::Scanner->new(), $class);
  $this->{tasktype} = $tasktype;
  $this->{restype} = $restype;
  $this->{resname} = $resname;
  $this->{instmodule} = $instmodule;
  return $this;
}

sub scanSource {
  my ($this, $context, $queue, $artifact, $resource, $task) = @_;
    
  # -- check task and resource masks
  if(($resource->getType() =~ /$this->{restype}/)
      && ($resource->getName()->asString() =~ /$this->{resname}/)
      && ($task->getType() =~ /$this->{tasktype}/)) {

    # -- scan the file
    my $filename = $resource->getPhysicalPathString();
    local *SRCFILE;
    if(!open(SRCFILE, "<" . $filename)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $SMake::ToolChain::Constructor::Constructor::SUBSYSTEM,
          "source %s cannot be opened", $filename);
    }
    while(my $line = <SRCFILE>) {
      if($line =~ /^\s*#\s*include\s*[<"]([^">]+)[">]/) {
        my $path = $1;
        $path =~ s/\\/\//;  # -- windows paths
        $this->installExternalResource(
            $context,
            $artifact,
            $resource,
            $task,
            $this->{instmodule},
            SMake::Data::Path->new($path));
      }
    }
    close SRCFILE;
  }
  else {
    return 0;
  }
}

return 1;
