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

# Append and resolve some new product resource during finishing of the artifact
package SMake::Profile::AppendResource;

use SMake::Profile::ArtifactProfile;

@ISA = qw(SMake::Profile::ArtifactProfile);

use SMake::Data::Path;
use SMake::Model::Const;
use SMake::ToolChain::Scanner::Fixed;
use SMake::ToolChain::Constructor::Constructor;
use SMake::Utils::Masks;

# Create new artifact profile
#
# Usage: new($typemask, $namemask, [$stage, $tasktype, $restype, $resname, \@externals]*)
#    typemask ...... a regular expression to match type of the artifact
#    namemask ...... a regular expression to match name of the artifact
#    stage ......... name of the stage
#    tasktype ...... name of the creation task
#    restype ....... type of the appended resource
#    resname ....... a description for the mangler. The name of the artifact is used
#                    as the resource name.
#    externals ..... list of tuples [$instmodule, $mangler] - records for the fixed scanner
#                    which is applied on the created resource
sub new {
  my ($class, $typemask, $namemask, @records) = @_;
  my $this = bless(SMake::Profile::ArtifactProfile->new($typemask, $namemask), $class);
  $this->{records} = \@records;
  return $this;
}

sub doBeginJob {
  # -- nothing to do
}

# Do job during artifact finishing
#
# Usage: doEndJob($context, $subsystem, $artifact)
#    context ..... parser context
#    subsystem ... logging subsystem
#    artifact .... the artifact object
sub doEndJob {
  my ($this, $context, $subsystem, $artifact) = @_;

  my $path = SMake::Data::Path->new($artifact->getName());

  # -- append all resources
  my $added = [];
  foreach my $record (@{$this->{records}}) {
    my ($stage, $tasktype, $restype, $resname, $externals) = @$record;
     
    # -- create name of the new resource
    my $tgpath = $context->getMangler()->mangleName(
        $context, $resname, $path);

    # -- create the task and resource
    my $task = $artifact->createTaskInStage(
        $context,
        $stage,
        $tgpath->asString(),
        $tasktype,
        $SMake::Model::Const::PRODUCT_LOCATION,
        $artifact->getPath(),
        undef);
    
    # -- create the resource
    my $tgres = $artifact->createProductResource(
        $context, $restype, $tgpath, $task);
    push @$added, $tgres;
    
    # -- append the fixed scanner
    my $scanner = SMake::ToolChain::Scanner::Fixed->new(
        '.*',
        SMake::Utils::Masks::createMask($restype),
        SMake::Utils::Masks::createMask($tgpath->asString()),
        0,
        $externals
    );
    $context->pushScanner($scanner);
  }
  
  # -- resolve the added resources
  $context->getToolChain()->getConstructor()->resolveResources(
      $context, $artifact, $added);
}

return 1;
