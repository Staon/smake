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

# List of files
package SMake::Executor::Translator::FileList;

use SMake::Executor::Translator::Value;

@ISA = qw(SMake::Executor::Translator::Value);

use SMake::Executor::Executor;
use SMake::Utils::Utils;

# Create new file list translator
#
# The translator expects as the value a container of resources
#
# Usage: new($address, $prefix, $suffix, $itemprefix, $itemsuffix, $separator, $sort, $mangler)
#    address ..... address of the container
sub new {
  my ($class, $address, $prefix, $suffix, $itemprefix, $itemsuffix, $separator, $sort, $mangler) = @_;
  my $this = bless(SMake::Executor::Translator::Value->new($address), $class);
  $this->{prefix} = $prefix;
  $this->{suffix} = $suffix;
  $this->{itemprefix} = $itemprefix;
  $this->{itemsuffix} = $itemsuffix;
  $this->{separator} = $separator;
  $this->{sortflag} = $sort;
  $this->{mangler} = $mangler;
  return $this;
}

sub translateValue {
  my ($this, $context, $command, $wd, $value) = @_;
  
  # -- get list of resource nodes
  my $reslist = $value->getChildren();
  
  # -- sort resources
  if($this->{sortflag}) {
    $reslist = [
        sort {$a->getPath()->getBasename() cmp $b->getPath()->getBasename()} @$reslist];
  }
  
  my $str = $this->{prefix};
  my $first = 1;
  foreach my $res (@$reslist) {
  	# -- separator
  	if($first) {
  	  $first = 0;
  	}
  	else {
  	  $str .= $this->{separator};
  	}
  	
  	# -- item prefix
    $str .= $this->{itemprefix};
    
    # -- file
    my $path = $res->getPath();
    my $relpath;
    ($relpath, $path) = $path->getDirpath()->systemArgument($wd, $path->getBasename());
    # -- mangle the filename
    if(defined($this->{mangler})) {
      $path = $context->getMangler()->mangleName($context, $this->{mangler}, $path);
    }
    if($relpath) {
      $str .= $path->systemRelative();
    }
    else {
      $str .= $path->systemAbsolute();
    }
    
    # -- item suffix
    $str .= $this->{itemsuffix};
  }
  $str .= $this->{suffix};
  
  return [$str];
}

return 1;
