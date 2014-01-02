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

# Generic project request interface. The request is used to select
# appropriate version, variant etc. of a project.
package SMake::Data::Request;

use SMake::Data::RequestContainer;
use SMake::Utils::Abstract;

# Create new request
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Append new request
#
# Usage: appendRequest($request)
# Returns: new constructed request
sub appendRequest {
  my ($this, $request) = @_;
  my $cont = SMake::Data::RequestContainer->new();
  $cont->appendRequest($this);
  $request->appendToContainer($cont);
  return $cont;
}

# Append this request into a container
#
# Usage: appendToContainer($cont)
sub appendToContainer {
  my ($this, $cont) = @_;
  $cont->appendRequest($this);
}

# Merge requests
#
# Usage: mergeRequest($request);
# Returns: new merged request
sub mergeRequest {
  my ($this, $request) = @_;
  my ($flag, $newreq) = $this->mergeRequestInternal($request);
  if(!$flag) {
    return $newreq->appendRequest($request);
  }
  else {
    return $newreq;
  }
}

# Merge requests
#
# Usage: mergeRequestInternal($request)
# Returns: (change flag, merged request)
sub mergeRequestInternal {
  SMake::Utils::Abstract::dieAbstract();
}

# Compose a printable string which represents the request
#
# Usage: printableString();
sub printableString {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
