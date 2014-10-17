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
# Usage: new($location, \@cpmodules)
#    location ..... location resource type of the installation area
#    cpmodules .... list of modules which the files are copied to instead of linking
sub new {
  my ($class, $location, $cpmodules) = @_;
  
  my $this = bless(SMake::InstallArea::InstallArea->new(), $class);
  $this->{location} = $location;
  if(defined($cpmodules)) {
    $this->{cpmodules} = { map { $_ => 1 } @$cpmodules };
  }
  else {
    $this->{cpmodules} = {};
  }
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

sub getPhysicalLocation {
  my ($this, $project, $resource) = @_;

  my $module = $resource->getType();
  my $path = $resource->getName();
  my $basepath = $this->getBasePath($project, $module);
  return $basepath->joinPaths($path);  
}

sub installResolvedResource {
  my ($this, $context, $subsystem, $project, $module, $name, $resolved) = @_;

  # -- area base path
  my $basepath = $this->getBasePath($project, $module);
      
  # -- prepare installation directory
  my $dirpath = $basepath->joinPaths($name->getDirpath());
  my $dirname = $project->getRepository()->getPhysicalLocationString(
      $this->{location}, $dirpath);
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
  my $tgname = $project->getRepository()->getPhysicalLocationString(
      $this->{location}, $dirpath->joinPaths($name->getBasepath()));
  if(!-f $tgname) {
    if(!defined($this->{cpmodules}->{$module})) {
      # -- symbolic link
      if(!SMake::Utils::Dirutils::linkFile($tgname, $srcname)) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "cannot link file '%s' to '%s'!",
            $srcname,
            $tgname);
      }
    }
    else {
      # -- copy the resource
      if(!SMake::Utils::Dirutils::copyFile($tgname, $srcname)) {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "cannot copy file '%s' to '%s'!",
            $srcname,
            $tgname);
      }
    }
    print "Installed resource '$srcname' as '$tgname'.\n";
  }
}

sub installResource {
  my ($this, $context, $subsystem, $project, $resource) = @_;
  
  # -- resolve the dependency closure of the external resource
  my $resolved_list = SMake::Utils::Searching::externalTransitiveClosure(
      $context, $subsystem, $resource);
  foreach my $res (@$resolved_list) {
    if(!$res->[2]) {
      $this->installResolvedResource(
          $context,
          $subsystem,
          $project,
          $res->[0]->getType(),
          $res->[0]->getName(),
          SMake::Utils::Searching::getRealResource($res->[1]));
    }
  }
}

sub installDependency {
  my ($this, $context, $subsystem, $project, $dependency) = @_;
  
  my $closure = {};
  $dependency->updateTransitiveClosure(
        $context, $SMake::Executor::Executor::SUBSYSTEM, $closure, $dependency->getArtifact(), '.*');
  foreach my $d (values %$closure) {
    if(defined($d->[1])) {
      $this->installResolvedResource(
          $context,
          $subsystem,
          $project,
          $dependency->getInstallModule(),
          $d->[1]->getName(),
          $d->[1]);
    }
  }
}

sub getModulePath {
  my ($this, $context, $subsystem, $module, $project) = @_;
  return $this->{location}, $this->getBasePath($project, $module);
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
  $path = $project->getRepository()->getPhysicalLocationString(
      $this->{location}, $path);
  SMake::Utils::Dirutils::removeDirectory($path);
}

return 1;
