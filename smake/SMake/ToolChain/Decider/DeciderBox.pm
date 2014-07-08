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

# Decider box - it keeps all known deciders and allows to compare stored
#   time stamps
package SMake::ToolChain::Decider::DeciderBox;

use SMake::ToolChain::Decider::DeciderList;

my $Is_QNX = $^O eq 'qnx';
if($Is_QNX) {
  require Digest::SHA::PurePerl;
  import Digest::SHA::PurePerl qw(sha1_hex);
}
else {
  require Digest::SHA;
  import Digest::SHA qw(sha1_hex);
}

# Create new decider box
#
# Usage: new($decider)
#    decider ..... used decider object
sub new {
  my ($class, $decider) = @_;
  return bless({
    decider => $decider,
  }, $class);
}

# Compute timestamp mark
#
# Usage: getMark($repository, $declist)
#    repository . smake repository
#    declist .... decider list of file paths
# Returns: the timestamp mark or null if some of the file doesn't exist
sub getMark {
  my ($this, $repository, $declist) = @_;
  
  my $basestr = "";
  my $paths = $declist->getOrderedList();
  foreach my $path (@$paths) {
    my $fspath = $path->systemAbsolute();
  	return undef if(! -f $fspath);
    $basestr .= $this->{decider}->getStamp($fspath);
  }
  return sha1_hex($basestr);
}

# Check if a file has changed
#
# Usage: hasChanged($path, $mark)
#    repository ... repository which the file belongs to
#    path ......... absolute path to the file
#    mark ......... stored decider mark. If the mark is empty or undef, new mark
#                   is always computed.
# Returns: undef value if the file is not changed, new decider mark if the file
#    is changed.
sub hasChanged {
  my ($this, $repository, $path, $mark) = @_;
  
  # -- get current mark
  my $phpath = $path->systemAbsolute();
  my $curr_mark = "";
  if(-f $phpath) {
    $curr_mark = sha1_hex($this->{decider}->getStamp($phpath));
  }
  
  # -- compare marks
  if($mark && $curr_mark eq $mark) {
    return undef;
  }
  else {
    return $curr_mark;
  }
}

return 1;
