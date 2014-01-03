# Implementation of the stage object for the external storage
package SMake::Repository::External::Stage;

use SMake::Model::Stage;

@ISA = qw(SMake::Model::Stage);

# Create new stage object
#
# Usage: new($repository, $artifact, $name)
sub new {
  my ($class, $repository, $artifact, $name) = @_;
  my $this = bless(SMake::Model::Stage->new(), $class);
  $this->{repository} = $repository;
  $this->{artifact} = $artifact;
  $this->{name} = $name;
  return $name;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getName {
  my ($this) = @_;
  return $this->{name};
}

sub getArtifact {
  my ($this) = @_;
  return $this->{artifact};
}

return 1;
