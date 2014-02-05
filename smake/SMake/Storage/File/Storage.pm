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

# File project storage
package SMake::Storage::File::Storage;

my $Is_QNX = $^O eq 'qnx';

use SMake::Storage::Storage;

@ISA = qw(SMake::Storage::Storage);

use Data::Dumper;
use File::Spec;
use SMake::Storage::File::Cache;
use SMake::Storage::File::Transaction;
use SMake::Utils::Dirutils;

if($Is_QNX) {
  require Digest::SHA::PurePerl;
  import Digest::SHA::PurePerl qw(sha1_hex);
}
else {
  require Digest::SHA;
  import Digest::SHA qw(sha1_hex);
}

# Create new file storage
#
# Usage: new($path)
#    path .... file system location (a directory) of the storage
sub new {
  my ($class, $path) = @_;
  my $this = bless(SMake::Storage::Storage->new(), $class);
  $this->{path} = $path;
  $this->{descriptions} = {};
  $this->{projects} = SMake::Storage::File::Cache->new(10);
  
  return $this;
}

# Load data of the storage
#
# Usage: loadStorage($repository)
sub loadStorage {
  my ($this, $repository_) = @_;
  
  # -- load table of descriptions
  my $filename = File::Spec->catfile($this->{path}, "descriptions");
  if(-f $filename) {
    my $data;
    {
      local $/ = undef;
      local *DESCFILE;
      open(DESCFILE, "<$filename");
      $data = <DESCFILE>;
      close(DESCFILE);
    }
  
    { 
      local $storage = $this;
      local $repository = $repository_;
      local $descriptions;
      my $info = eval $data;
      if(!defined($info) && (defined($@) && $@ ne "")) {
        die "it's not possible to read storage data from file '$filename'!";
      }
      $this->{descriptions} = $descriptions;
    }
  }
}

sub destroyStorage {
  # -- nothing to do
}

# Save content of a project into a file
#
# Usage: storeProject($repository, $key, $project)
sub storeProject {
  my ($this, $repository, $key, $project) = @_;

  # -- store into the cache
  $this->{projects}->insertProject($project);
  
  # -- make directory (to be sure)
  my $directory = File::Spec->catdir($this->{path}, "projects");
  SMake::Utils::Dirutils::makeDirectory($directory);
  
  # -- generate unique file name
  my $filename = sha1_hex($key);
  $filename = File::Spec->catfile($directory, $filename);

  # -- dump the project
  {
    local *PRJFILE;
    open(PRJFILE, ">$filename");
    my $dumper = Data::Dumper->new([$project], [qw(project)]);
    $dumper->Indent(1);
    $dumper->Purity(1);
    $dumper->Seen({'repository' => $repository, 'storage' => $this});
    print PRJFILE $dumper->Dump();
    close(PRJFILE);
  }
}

# Get a project from the cache or load it from file
#
# Usage: loadProject($repository, $key)
# Returns: the project or undef (if it's not known)
sub loadProject {
  my ($this, $repository_, $key) = @_;
  
  # -- check the cache
  {
    my $project = $this->{projects}->getProject($key);
    return $project if(defined($project));
  }
  
  # -- generate file name
  my $filename = sha1_hex($key);
  $filename = File::Spec->catfile(($this->{path}, "projects"), $filename);
  
  if(-f $filename) {
    # -- read the content
    my $data;
    {
      local $/ = undef;
      local *PRJFILE;
      open(PRJFILE, "<$filename");
      $data = <PRJFILE>;
      close(PRJFILE);
    }

    { 
      local $storage = $this;
      local $repository = $repository_;
      local $project;
      my $info = eval $data;
      if(!defined($info) && (defined($@) && $@ ne "")) {
        die "it's not possible to read project data from file '$filename'!";
      }
      
      $this->{projects}->insertProject($project);
      return $project;
    }
  }
  
  return undef;
}

# Delete stored data of a project
#
# Usage: deleteProject($repository, $key)
#    key ..... project's key
sub deleteProject {
  my ($this, $repository, $key) = @_;

  # -- remove from the cache
  $this->{projects}->removeProject($key);
  
  # -- delete the file
  my $filename = sha1_hex($key);
  $filename = File::Spec->catfile(($this->{path}, "projects"), $filename);
  unlink($filename);
}

# Get description object according to its key
#
# Usage: getDescriptionKey($key)
sub getDescriptionKey {
  my ($this, $key) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->getDescriptionKey($key);
}

sub openTransaction {
  my ($this, $repository) = @_;
  $this->{transaction} = SMake::Storage::File::Transaction->new($this);
}

sub commitTransaction {
  my ($this, $repository) = @_;
  if(defined($this->{transaction})) {
    # -- commit changes
    $this->{transaction}->commit($repository);
    
    # -- store the table of descriptions
    {
      my $filename = File::Spec->catfile($this->{path}, "descriptions");
      local *DESCFILE;
      open(DESCFILE, ">$filename");
      my $dumper = Data::Dumper->new([$this->{descriptions}], [qw(descriptions)]);
      $dumper->Indent(1);
      $dumper->Purity(1);
      $dumper->Seen({'repository' => $repository, 'storage' => $this});
      print DESCFILE $dumper->Dump();
      close(DESCFILE);
    }
  }
}

sub createDescription {
  my ($this, $repository, $parent, $path, $mark) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->createDescription($repository, $parent, $path, $mark);
}

sub getDescription {
  my ($this, $repository, $path) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->getDescription($repository, $path);
}

sub removeDescription {
  my ($this, $repository, $path) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  $this->{transaction}->removeDescription($repository, $path);
}

sub createProject {
  my ($this, $repository, $name, $path) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->createProject($repository, $name, $path);
}

sub getProject {
  my ($this, $repository, $name, $path) = @_;
  die "not opened transaction" if(!defined($this->{transaction}));
  return $this->{transaction}->getProject($repository, $name);
}

return 1;
