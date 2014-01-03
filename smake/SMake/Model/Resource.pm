# Generic resource object
package SMake::Model::Resource;

use SMake::Model::Object;

@ISA = qw(SMake::Model::Object);

use SMake::Utils::Abstract;

# Create new resource
sub new {
  my ($class) = @_;
  return bless(SMake::Model::Object->new(), $class);
}

# Get name of the resource
sub getName {
  SMake::Utils::Abstract::dieAbstract();
}

# Get logical path of the resource
sub getPath {
  SMake::Utils::Abstract::dieAbstract();
}

# Get logical relative path based on the artifact
sub getRelativePath {
  SMake::Utils::Abstract::dieAbstract();
}

return 1;
