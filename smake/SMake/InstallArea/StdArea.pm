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
# Usage: new($restype)
#    restype ...... resource type of the installation area. The area can be placed
#                   into the source tree or into the product tree
sub new {
  my ($class, $restype) = @_;
  my $this = bless(SMake::InstallArea::InstallArea->new(), $class);
  $this->{restype} = $restype;
  return $this;
}

sub getBasePath {
  my ($this, $project, $module) = @_;
  
  if(defined($module)) {
    return $project->getPath()->joinPaths(".install", $module);
  }
  else {
    return $project->getPath()->joinPaths(".install");
  }
}

sub installResolvedResource {
  my ($this, $context, $subsystem, $project, $module, $name, $resolved) = @_;

  # -- area base path
  my $basepath = $this->getBasePath($project, $module);
  print "$module " . $basepath->asString() . "\n";
      
  # -- prepare installation directory
  my $dirpath = $basepath->joinPaths($name->getDirpath());
  my $dirname = $context->getRepository()->getPhysicalLocationString(
      $this->{restype}, $dirpath);
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
  my $srcname = $resolved->getPhysicalPathString();
  my $tgname = $context->getRepository()->getPhysicalLocationString(
      $this->{restype}, $dirpath->joinPaths($name->getBasepath()));
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
          $context,
          $subsystem,
          $project,
          $resource->getName()->getPart(0),
          $resource->getName()->removePrefix(1),
          $resolved);
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
  $this->installResolvedResource(
      $context,
      $subsystem,
      $project,
      $dependency->getInstallModule(),
      $resource->getName(),
      $resource);
}

sub getModulePath {
  my ($this, $context, $subsystem, $module, $project) = @_;
  return $this->{restype}, $this->getBasePath($project, $module);
}

# Clean the installation area
#
# Usage: cleanArea($context, $subsystem, $project)
#    context ..... executor context
#    subsystem ... logging subsystem
#    project ..... project object which the resource is installed in
sub cleanArea {
  my ($this, $context, $subsystem, $project) = @_;

  my $path = $this->getBasePath($project);
  $path = $context->getRepository()->getPhysicalLocationString(
      $this->{restype}, $path);
  SMake::Utils::Dirutils::removeDirectory($path);
}

return 1;
