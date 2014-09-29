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

# Data dumper based on the Data::Dumper class
package SMake::Storage::File::DataDumper;

use SMake::Storage::File::Dumper;

@ISA = qw(SMake::Storage::File::Dumper);

use Data::Dumper;

# Ctor
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Storage::File::Dumper->new(), $class);
  return $this;
}

sub dumpObject {
  my ($this, $repository, $storage, $filename, $object) = @_;

  local *PRJFILE;
  open(PRJFILE, ">$filename");
  my $dumper = Data::Dumper->new([$object], [qw(object)]);
  $dumper->Indent(1);
  $dumper->Purity(1);
  $dumper->Seen({'repository' => $repository, 'storage' => $storage});
  print PRJFILE $dumper->Dump();
  close(PRJFILE);
}

sub loadObject {
  my ($this, $repository_, $storage_, $filename) = @_;

  if(-f $filename) {
    # -- read the content
    local $storage = $storage_;
    local $repository = $repository_;
    local $object;
    local $/ = undef;
    local *PRJFILE;
    open(PRJFILE, "<$filename");
    my $info = eval <PRJFILE>;
    close(PRJFILE);
    if(!defined($info) && (defined($@) && $@ ne "")) {
      die "it's not possible to read project data from file '$filename'!";
    }
    
    return $object;
  }
  
  return undef;
}

return 1;
