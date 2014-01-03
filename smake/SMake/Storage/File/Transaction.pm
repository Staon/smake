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

# State of project storage transaction
package SMake::Storage::File::Transaction;

use SMake::Storage::File::Description;
use SMake::Storage::File::Project;

# Create new transaction state
#
# Usage: new($storage)
sub new {
  my ($class, $storage) = @_;
  return bless({
    storage => $storage,
    prjnew => {},
    prjdel => {},
    descrnew => {},
  }, $class);
}

# Create new description object
#
# Usage: createDescription($repository, $path, $mark)
#    repository ... owning repository
#    path ......... logical path of the description file
#    mark ......... decider's mark of the description file
sub createDescription {
  my ($this, $repository, $path, $mark) = @_;
  my $descr = SMake::Storage::File::Description->new($repository, $path, $mark);
  $this->{descrnew}->{$descr->getKey()} = $descr;
  return $descr;
}

# Create new project object
#
# Usage: createProject($repository, $name, $path)
#    repository ... owning repository
#    name ......... name of the project
#    path ......... logical path of the project
sub createProject {
  my ($this, $repository, $name, $path) = @_;
  my $prj = SMake::Storage::File::Project->new($repository, $name, $path);
  $this->{prjnew}->{$prj->getKey()} = $prj;
  return $prj;
}

# Commit the transaction
#
# Usage: commit()
sub commit {
  my ($this) = @_;
  @{$this->{storage}->{projects}}{keys %{$this->{prjnew}}} 
      = values %{$this->{prjnew}};
  # -- there is no need to merge the description objects - it'll be done
  #    explicitely by iterating of the projects.
}

return 1;
