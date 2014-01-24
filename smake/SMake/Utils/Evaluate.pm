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

package SMake::Utils::Evaluate;

sub AUTOLOAD {
  my $name = $AUTOLOAD;
  $name =~ s/.*:://;
  if(defined($evaluation_context->{$name}) && ref($evaluation_context->{$name}) eq "CODE") {
    &{$evaluation_context->{$name}}($name, @_);
  }
  else {
    die "Unknown directive '$name'!"
  }
}

# Evaluate a script
#
# Usage: evaluateScript($script, \%context)
#    script...... path of the file
#    context .... hash table of configuration values. All keys are transformed
#        into global variables (only for the file) with filled values.
# Returns: undef if everything is OK, an error message otherwise.
sub evaluateScript {
  my ($script, $context) = @_;
  
  local *evaluation_context = \$context;
  my $full_script = "";
  for my $varname (keys(%$context)) {
    $full_script .= 'local *' . $varname . ' = \$evaluation_context->{' 
        . $varname . '};' . "\n";
  }
  $full_script .= $script;
  local $SIG{__WARN__} = sub { die @_ };
  my $info = eval $full_script;
  if(!defined($info) && (defined($@) && $@ ne "")) {
    my $message = $@;
    $message =~ s/\n*$//;
    return $message;
  }
  
  return undef;
}

# Evaluate a specification file (SMakefile, configuration file etc.)
#
# Usage: evaluateSpecFile($path, \%context)
#    path ....... path of the file
#    context .... hash table of configuration values. All keys are transformed
#        into global variables (only for the file) with filled values.
# Returns: undef if everything is OK, an error message otherwise.
sub evaluateSpecFile {
  my ($path, $context) = @_;

  # Read (slurp) the script file
  my $script;
  if(-f $path) {
    local $/ = undef;
    local *SCRIPTFILE;
    open(SCRIPTFILE, "<$path");
    $script = <SCRIPTFILE>;
    close(SCRIPTFILE);
  }
  else {
  	return "File $path doesn't exist.";
  }
  
  return evaluateScript($script, $context);
}

return 1;
