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

# Projects visibility
package SMake::Parser::Visibility;

# Create new visibility object
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless({}, $class);
  $this->{projects} = {};
  return $this;
}

# Create new project or use already existing. The project cannot be present
# in the visibility list.
#
# Usage: createProject($context, $subsystem, $name)
sub createProject {
  my ($this, $context, $subsystem, $name) = @_;

  # -- check existence of the project  
  my $record = $this->{projects}->{$name};
  if(defined($record)) {
    SMake::Utils::Utils::dieReport(
        $context->getReporter(),
        $subsystem,
        "project '%s' is already present in the visibility list!",
        $name);
  }

  # -- get the repository object
  my ($project, $external) = $context->getRepository()->getProject($name);
  if(!defined($project)) {
    $project = $context->getRepository()->createProject($name);
  }
  
  # -- create new record
  $record = [$name, 0];  # -- not external
  $this->{projects}->{$name} = $record;
  
  return $project;
}

# Get project existing project
#
# Usage: getProject($context, $subsystem, $name)
#    context ......... parser/executor context
#    subsystem ....... error subsystem
#    name ............ name of the project
# Returns: the project or undef
# Note: if the optional arguments are specified they must matches already
#    existing project record.
sub getProject {
  my ($this, $context, $subsystem, $name) = @_;
  
  my $record = $this->{projects}->{$name};
  if(!defined($record)) {
    $record = [$name, 1];
  }

  # -- search for the project object
  my ($project, $external) = $context->getRepository()->getProject($record->[0]);
  if(defined($project)) {
    $record->[1] = $record->[1] && $external;
    $this->{projects}->{$name} = $record;
  }
  
  return $project;
}

# Create list of root stages
#
# The method creates a list of stages which can be used as roots to compute
# topological order of dependent stages. The list can be directly passed
# into the executor.
#
# Usage: createRootList($context, $subsystem, $artifact, $stage)
#    context ...... parser/executor context
#    subsystem .... logging subsystem
#    project ...... a regulat expression to match projects
#    artifact ..... a regular expression to match artifacts
#    stage ........ name of root stages
# Returns: \@list
#    list of stage addresses
sub createRootList {
  my ($this, $context, $subsystem, $project, $artifact, $stage) = @_;
  
  my $list = [];
  foreach my $record (values %{$this->{projects}}) {
    my $prj = $context->getVisibility()->getProject(
        $context, $subsystem, $record->[0]);
    if(!defined($prj)) {
      SMake::Utils::Utils::dieReport(
          $context->getReporter(),
          $subsystem,
          "unknown project '%s'",
          $record->[0]);
    }
    
    if($prj->getName() =~ /$project/) {
      my $artifacts = $prj->getArtifacts();
      foreach my $art (@$artifacts) {
        if($art->getName() =~ /$artifact/) {
          $st = $art->getStage($stage);
          if(defined($st)) {
            push @$list, $st->getAddress();
          }
        }
      }
    }
  }
  
  return $list;
}

# Check if a project is external
#
# Usage: isExternal($name)
#    name ..... name of the project
# Returns: true if the project is external
sub isExternal {
  my ($this, $name) = @_;
  return $this->{projects}->{$name}->[1];
}

return 1;
