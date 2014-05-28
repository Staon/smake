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

# Generic compilation builder
package SMake::Executor::Builder::Compile;

use SMake::Executor::Builder::Builder;

@ISA = qw(SMake::Executor::Builder::Builder);

use SMake::Executor::Command::Group;
use SMake::Executor::Command::Option;
use SMake::Executor::Command::Resource;
use SMake::Executor::Command::Set;
use SMake::Executor::Const;
use SMake::Model::Const;

# Create new compilation builder
#
# Usage: new($bldfce*)
#    bldfce .... name of a building function. The builder sequentially invokes
#                the functions. Set of possible functions can be found in
#                the Builder class. If the list is empty, the addResources
#                function is called.
sub new {
  my $class = shift;
  my $this = bless(SMake::Executor::Builder::Builder->new(), $class);
  if($#_ >= 0) {
    $this->{builders} = [@_];
  }
  else {
    $this->{builders} = ["addResources"];  	
  }
  
  return $this;
}

sub build {
  my ($this, $context, $task) = @_;
  
  my $command = SMake::Executor::Command::Set->new($task->getType());
  foreach my $bld (@{$this->{builders}}) {
    $this->$bld($context, $task, $command);
  }
  return [$command];
}

return 1;
