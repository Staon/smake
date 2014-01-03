# Implementation of the resource object for the external repository
package SMake::Repository::External::Resource;

use SMake::Model::Resource;

@ISA = qw(SMake::Model::Resource);

# Create new resource
#
# Usage: new($repository, $basepath, $prefix, $name)
#    repository ... a repository which the resource belongs to
#    basepath ..... path of the artifact
#    prefix ....... a relative path based on the artifact
#    name ......... name of the resource (as a relative path based on the artifact)
sub new {
  my ($class, $repository, $basepath, $prefix, $name) = @_;
  my $this = bless(SMake::Model::Resource->new(), $class);
  $this->{repository} = $repository;
  $this->{name} = $prefix->joinPaths($name);
  $this->{path} = $basepath->joinPaths($prefix, $name);
  return $this;
}

sub getRepository {
  my ($this) = @_;
  return $this->{repository};
}

sub getName {
  my ($this) = @_;
  return $this->{name}->asString();
}

sub getPath {
  my ($this) = @_;
  return $this->{path};
}

sub getRelativePath {
  my ($this) = @_;
  return $this->{name};
}

return 1;
