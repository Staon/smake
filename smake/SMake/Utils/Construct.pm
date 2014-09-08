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

# Helper functions for project construction
package SMake::Utils::Construct;

use SMake::Data::Path;
use SMake::Model::Const;

# A helper method - install an external resource
#
# Usage: installExternalResource($context, $artifact, $resource, $task, $path)
#    context ...... parser context
#    artifact ..... artifact of the scanned resource
#    resource ..... the scanned resource
#    task ......... a task which the scanned resource is a source for
#    module ....... installation module
#    name ......... name of the external resource
sub installExternalResource {
  my ($context, $artifact, $resource, $task, $module, $name) = @_;

  # -- create the installation stage
  $name = SMake::Data::Path->new($name);
  my $stagename = "install:" . $name->asString();
  my $stage = $artifact->getStage($stagename);
  my $extres;
  if(!defined($stage)) {
    # -- create installation task
    my $insttask = $artifact->createTaskInStage(
        $context,
        $stagename,
        $stagename,
        $SMake::Model::Const::EXTERNAL_TASK,
        undef,
        undef,
        undef);
    # -- create the external resource
    $extres = $artifact->createResource(
        $context,
        $SMake::Model::Const::EXTERNAL_LOCATION,
        $module,
        $name,
        $insttask);
  }
  else {
    $extres = $artifact->getResource(
        $SMake::Model::Const::EXTERNAL_LOCATION, $module, $name);
    if(!defined($extres)) {
      die "there is something wrong: resource '" . $name->asString() . "' is missing!";
    }
  }
  
  # -- append stage dependency
  $task->appendSource($context, $extres);
}

# Parse a dependency specification
#
# Usage: parseDependencySpec($baseprj, \@specs)
#    baseprj ...... name of the base project (which is used for artifacts without project specification)
#    specs ........ list of dependency specifications
# Returns: [[$project, $artifact, $mainres]*]
#    list of tuples. The mainres can be undef for default main resource
sub parseDependencySpecs {
  my ($baseprj, $specs) = @_;

  my $added = [];
  foreach my $dep (@$specs) {
    if(ref($dep) eq "ARRAY") {
      # -- array record
      my $project = $dep->[0];
      my $artspec;
      if(ref($dep->[1]) eq "ARRAY") {
        $artspec = $dep->[1];
      }
      else {
        $artspec = [@$dep];
        shift @$artspec;
        if($#$artspec > 0) {
          $artspec = [$artspec];
        }
      }
      
      foreach my $spec (@$artspec) {
        my ($artifact, $mainres);
        if(ref($spec) eq "ARRAY") {
          ($artifact, $mainres) = @$spec;
        }
        else {
          # -- string record
          if($spec =~ /^([^\/\@]+)(\@[^\/]+)?$/) {
            ($artifact, $mainres) = ($1, $2);
            if(defined($mainres)) {
              $mainres =~ s/^\@//;
            }
          }
          else {
            SMake::Utils::Utils::dieReport(
                $context->getReporter(),
                $subsystem,
                "string '%s' is not a valid dependency specification (artifact[\@mainres])",
                $dep->[1]);
          }
        }
        push @$added, [$project, $artifact, $mainres];
      }
    }
    else {
      # -- string record, parse it
      if($dep =~ /^([^\/]+\/)?([^\/\@]+)(\@[^\/]+)?$/) {
        my ($project, $artifact, $mainres) = ($1, $2, $3);
        if(defined($project)) {
          $project =~ s/[\/]$//;
        }
        else {
          $project = $baseprj;
        }
        if(defined($mainres)) {
          $mainres =~ s/^\@//;
        }
        push @$added, [$project, $artifact, $mainres];
      }
      else {
        SMake::Utils::Utils::dieReport(
            $context->getReporter(),
            $subsystem,
            "string '%s' is not a valid dependency specification ([project/]artifact[\@mainres])",
            $dep);
      }
    }
  }
  
  return $added;
}

return 1;
