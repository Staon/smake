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

# External repository - only keeps info about external project. The repository
# is used for development, it registers projects in developer's working
# directories.
package SMake::Repository::External::Repository;

use SMake::Repository::Repository;

@ISA = qw(SMake::Repository::Repository);

use File::Spec;
use SMake::Data::VariantFree;
use SMake::Repository::External::Description;
use SMake::Repository::External::Project;
use SMake::Repository::External::ProjectClean;
use SMake::Repository::External::ProjectDirty;
use SMake::Utils::Evaluate;

sub constructRepFileName {
  my ($path) = @_;
  return File::Spec->catfile($path, ".smakerep");
}

sub smakerep_Project {
  my ($directive, $name, $path) = @_;
  $repository->{projects}->{$name} 
      = SMake::Repository::External::ProjectDirty->new($name, $path);
}

# Create new external repository
#
# Usage: new($parent, $path)
#    parent .... parent repository
#    path ...... path to the repository (the repository stores project metadata here)
sub new {
  my ($class, $parent, $path) = @_;
  my $this = bless(SMake::Repository::Repository->new($parent), $class);
  $this->{path} = $path;
  $this->{projects} = {};
  $this->{descriptions} = {};
  
  # -- read repository configuration
  my $cfgfile = File::Spec->catfile($path, ".reprc");
  SMake::Utils::Evaluate::evaluateSpecFile($cfgfile, { repository => $this });
  
  # -- read content of the repository
  my $repfile = constructRepFileName($path);
  if(-f $repfile) {
  	local $repository = $this;
    SMake::Utils::Evaluate::evaluateSpecFile(
        $repfile, { Project => \&smakerep_Project });
  }
  
  return $this;
}

sub destroyRepository {
  my ($this) = @_;
  
  local *REPFILE;
  my $repfile = constructRepFileName($this->{path});
  open(REPFILE, ">$repfile");
  for my $project (keys(%{$this->{projects}})) {
    $this->{projects}->{$project}->writeData(\*REPFILE);
  }
  close(REPFILE);
}

# Get version identifier configured for this repository
sub getVersion {
  my ($this) = @_;
  return $this->{version};
}

# Set the version object which is used by the repository (the external repository
# works with one pre-configured version)
#
# Usage: setVersion($version)
sub setVersion {
  my ($this, $version) = @_;
  $this->{version} = $version;
}

# Get identifier of the fixed variant
sub getVariant {
  return SMake::Data::VariantFree->new();
}

# Set project object
#
# Usage: setProject($name, $project)
sub setProject {
  my ($this, $name, $project) = @_;
  $this->{projects}->{$name} = $project;
}

sub getPhysicalPath {
  my ($this, $location) = @_;
  # The external storage keeps absolute paths as the resource locations
  return $location->systemAbsolute();
}

sub createDescription {
  my ($this, $path, $mark) = @_;
  my $descr = SMake::Repository::External::Description->new($this, $path, $mark);
  $this->{descriptions}->{$path->hashKey()} = $descr;
  return $descr;
}

sub createProject {
  my ($this, $name, $path) = @_;
  return SMake::Repository::External::Project->new($this, $name, $path);
}

sub acceptProject {
  my ($this, $project) = @_;
  my $wrapper = SMake::Repository::External::ProjectClean->new($project);
  $this->{projects}->{$project->getName()} = $wrapper;
}

return 1;
