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

sub getBasePath {
  my ($this, $project, $module) = @_;
  return $project->getPath()->joinPaths(".install", $module);
}

sub getBasePathForName {
  my ($this, $context, $subsystem, $project, $name) = @_;

  # -- get module name (first part of the resource path)
  if($name->getSize() < 2) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "path '%s' is not a valid path of an installable resource",
        $name->asString());
  }
  my $module = $name->getPart(0);
  $name = $name->removePrefix(1);
  return $this->getBasePath($project, $module), $name;
}

sub installResolvedResource {
  my ($this, $context, $subsystem, $project, $name, $resolved) = @_;

  # -- area base path
  my ($basepath, $path) = $this->getBasePathForName(
      $context, $subsystem, $project, $name);
      
  # -- prepare installation directory
  my $dirpath = $basepath->joinPaths($path->getDirpath());
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
      $dirpath->joinPaths($name->getBasepath()));
  if(!SMake::Utils::Dirutils::linkFile($tgname, $srcname)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $subsystem,
          "cannot link file '%s' to '%s'!",
          $srcname,
          $tgname);
  }
  
  print "Installed resource '$srcname' as '$tgname'.\n";
}

sub installResource {
  my ($this, $context, $subsystem, $project, $resource) = @_;
  
  # -- resolve the external resource
  my ($found, $resolved, $local) = SMake::Utils::Searching::resolveExternal(
      $context, $subsystem, $resource);
  if($found) {
    if(defined($resolved) && !$local) {
      $this->installResolvedResource(
          $context, $subsystem, $project, $resource->getName(), $resolved);
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

sub installDependency {
  my ($this, $context, $subsystem, $project, $dependency) = @_;
  
  my ($depproject, $artifact, $stage, $resource) = $dependency->getObjects(
      $context, $subsystem);
  my $instname = SMake::Data::Path->new($dependency->getInstallModule());
  $instname = $instname->joinPaths($resource->getName());
  $this->installResolvedResource(
      $context, $subsystem, $project, $instname, $resource);
}

sub getModulePath {
  my ($this, $context, $subsystem, $module, $project) = @_;
  return $this->getBasePath($project, $module);
}

return 1;
