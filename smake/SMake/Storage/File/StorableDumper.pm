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

# Data dumper based on the Storable interface
package SMake::Storage::File::StorableDumper;

use SMake::Storage::File::Dumper;

@ISA = qw(SMake::Storage::File::Dumper);

use Data::Dumper;
use Scalar::Util 'refaddr';
use SMake::Storage::File::ActiveFeature;
use SMake::Storage::File::Artifact;
use SMake::Storage::File::Dependency;
use SMake::Storage::File::DepSpec;
use SMake::Storage::File::Feature;
use SMake::Storage::File::Project;
use SMake::Storage::File::Resource;
use SMake::Storage::File::Stage;
use SMake::Storage::File::Task;
use SMake::Storage::File::TaskDependency;
use SMake::Storage::File::Timestamp;
use Storable qw(nstore_fd fd_retrieve);

sub freeze_method {
  my ($this, $cloning) = @_;
  return if($cloning);
  
  # -- pack attributes which can be serialized
  my $struct = {};
  foreach my $childname (keys %$this) {
    if($childname ne "storage" && $childname ne "repository") {
      $struct->{$childname} = $this->{$childname};
    }
  }

  return ("", $struct);
}

sub thaw_method {
  my ($this, $cloning, $data, $struct) = @_;
  
  # -- repository and storage are "local"-ized
  $this->{repository} = $repository;
  $this->{storage} = $storage;
  
  # -- copy deserialized data from the structure
  foreach my $childname (keys %$struct) {
    $this->{$childname} = $struct->{$childname};
  }
}

# -- register the serialization/deserialization methods to all storage objects
BEGIN {
  *SMake::Storage::File::ActiveFeature::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Artifact::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Dependency::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::DepSpec::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Feature::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Project::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Resource::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Stage::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Task::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::TaskDependency::STORABLE_freeze = \&freeze_method;
  *SMake::Storage::File::Timestamp::STORABLE_freeze = \&freeze_method;

  *SMake::Storage::File::ActiveFeature::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Artifact::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Dependency::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::DepSpec::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Feature::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Project::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Resource::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Stage::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Task::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::TaskDependency::STORABLE_thaw = \&thaw_method;
  *SMake::Storage::File::Timestamp::STORABLE_thaw = \&thaw_method;
}

# Ctor
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Storage::File::Dumper->new(), $class);
  return $this;
}

sub dumpObject {
  my ($this, $repository_, $storage_, $filename, $object) = @_;

  local *PRJFILE;
  local $repository = $repository_;
  local $storage = $storage_;
  open(PRJFILE, ">$filename");
  nstore_fd($object, \*PRJFILE);
  close(PRJFILE);
}

sub loadObject {
  my ($this, $repository_, $storage_, $filename) = @_;

  if(-f $filename) {
    # -- read the content
    local $storage = $storage_;
    local $repository = $repository_;
    local *PRJFILE;
    open(PRJFILE, "<$filename");
    my $object = fd_retrieve(\*PRJFILE);
    close(PRJFILE);
    if(!defined($object)) {
      die "it's not possible to read project data from file '$filename'!";
    }
    
    return $object;
  }
  
  return undef;
}

return 1;
