# Generic stage object
package SMake::Model::Stage;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new stage object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the stage
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get artifact which the stage belongs to
sub getArtifact {
  SMake::Utils::Abstract::dieAbstract();
}

# Get project which the state belongs to
sub getProject {
  my ($this) = @_;
  return $this->getArtifact()->getProject();
}

return 1;
