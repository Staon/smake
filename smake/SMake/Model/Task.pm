# Generic task interface
package SMake::Model::Task;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new task object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get type of the task
sub getType {
  SMake::Utils::Abstract::dieAbstract();
}

# Get arguments of the task
#
# The arguments are a hash table with a content which meaning depends on the type
# of the task.
sub getArguments {
  SMake::Utils::Abstract::dieAbstract();
}

# Get stage which the task belongs to
sub getStage {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
