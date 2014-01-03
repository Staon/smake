# Generic model object
package SMake::Model::Object;

use SMake::Utils::Abstract;

# Create new object
#
# Usage: new()
sub new {
  my ($class) = @_;
  return bless({}, $class);
}

# Get repository which the object belongs to
sub getRepository {
  SMake::Utils::Abstract::dieAbstract();
}

# Get physical (absolute) path of object. This method works only for objects
# which define method getPath (get resource location).
sub getPhysicalPath {
  my ($this) = @_;
  return $this->getRepository()->getPhysicalPath($this->getPath());
}

return 1;
