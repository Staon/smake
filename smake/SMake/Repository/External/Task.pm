# Implementation of the task object for the external repository
package SMake::Repository::External::Task;

use SMake::Model::Task;

@ISA = qw(SMake::Model::Task);

# Create new task object
#
# Usage: new($repository, $stage, $type, \%args)
sub new {
  my ($class, $repository, $stage, $type, $args) = @_;
  my $this = bless(SMake::Model::Task->new(), $class);
  $this->{repository} = $repository;
  $this->{stage} = $stage;
  $this->{type} = $type;
  $this->{args} = $args;
  
  return $this;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getType {
  my ($this) = @_;
  return $this->{type};
}

sub getArguments {
  my ($this) = @_;
  return $this->{args};
}

sub getStage {
  my ($this) = @_;
  return $this->{stage};
}

return 1;