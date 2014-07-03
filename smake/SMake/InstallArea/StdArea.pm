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

# Standard installation area
package SMake::InstallArea::StdArea;

use SMake::InstallArea::InstallArea;

@ISA = qw(SMake::InstallArea::InstallArea);

use SMake::Utils::Dirutils;
use SMake::Utils::Searching;
use SMake::Utils::Utils;

# Create new installation area
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::InstallArea::InstallArea->new(), $class);
  return $this;
}

# Install an external resource
#
# Usage: installResource($context, $subsystem, $project, $resource)
#    context ..... executor context
#    subsystem ... logging subsystem
#    project ..... project object which the resource is installed in
#    resource .... installed external resource
sub installResource {
  my ($this, $context, $subsystem, $project, $resource) = @_;
  
  # -- resolve the external resource
  my ($found, $resolved, $local) = SMake::Utils::Searching::resolveExternal(
      $context, $subsystem, $resource);
  if($found) {
    if(defined($resolved) && !$local) {
      # -- area base path
      my $basepath = $project->getPath()->joinPaths(".install");
      
      # -- prepare installation directory
      my $dirpath = $basepath->joinPaths($resource->getName()->getDirpath());
      my $dirname = $context->getRepository()->getPhysicalPath($dirpath);
      if(! -d $dirname) {
        my $msg = SMake::Utils::Dirutils::makeDirectory($dirname);
        if($msg) {
          SMake::Utils::Utils::dieReport(
              $context->getReporter(),
              $subsystem,
              "cannot create installation area path '%s': %s!",
              $dirname,
              $msg);
        }
      }
      
      # -- install the resource
      my $srcname = $context->getRepository()->getPhysicalPath($resolved->getPath());
      my $tgname = $context->getRepository()->getPhysicalPath(
          $dirpath->joinPaths($resource->getName()->getBasepath()));
      if(!SMake::Utils::Dirutils::linkFile($tgname, $srcname)) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "cannot link file '%s' to '%s'!",
            $srcname,
            $tgname);
      }
    }
  }
  else {
    SMake::Utils::Utils::dieReport(
         $context->getReporter(),
         $subsystem,
         "cannot resolve external resource '%s'!",
         $resource->getName()->asString());
  } 
}

return 1;
