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

# Generic file resolver
package SMake::Resolver::Compile;

use SMake::Resolver::Resource;

@ISA = qw(SMake::Resolver::Resource);

# Create new resolver
#
# Usage: new($type, $file, $mangler)
#    type ...... mask of type of the resources
#    file ...... mask of path of the resources
#    mangler ... mangler description
sub new {
  my ($class, $type, $file, $mangler) = @_;
  my $this = bless(SMake::Resolver::Resource->new($type, $file), $class);
  $this->{mangler} = $mangler;
  return $this;
}

sub doJob {
  my ($this, $context, $queue, $resource) = @_;

  # -- create name of the new resource
  my $tgpath = $context->getMangler()->mangleName(
      $context, $this->{mangler}, $resource->getRelativePath());

  # -- create the task and the resource
  my $artifact = $context->getArtifact();
  my $task = $artifact->createTaskInStage("compile", "cxx", undef);
  $task->appendSource($resource);
  my $tgres = $artifact->createResource($tgpath, "product", $task);
  $queue->pushResource($tgres);
}

return 1;
