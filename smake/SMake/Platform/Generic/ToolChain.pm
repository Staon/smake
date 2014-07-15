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

# Generic tool chain object - it contains root containers of all
# constructing objects and allows to register theirs children.
package SMake::Platform::Generic::ToolChain;

use SMake::ToolChain::ToolChain;

@ISA = qw(SMake::ToolChain::ToolChain);

use SMake::Executor::Builder::Compile;
use SMake::Executor::Builder::Empty;
use SMake::Executor::Builder::Group;
use SMake::Executor::Instruction::Clean;
use SMake::Executor::Instruction::CleanInstallArea;
use SMake::Executor::Instruction::Install;
use SMake::Executor::Translator::Instruction;
use SMake::Executor::Translator::Table;
use SMake::Model::Const;
use SMake::ToolChain::Constructor::Generic;
use SMake::ToolChain::Constructor::Table;
use SMake::ToolChain::Mangler::Mangler;
use SMake::ToolChain::Resolver::Chain;
use SMake::ToolChain::ResourceFilter::Chain;
use SMake::ToolChain::Scanner::Chain;

# Create new tool chain object
#
# Usage: new()
sub new {
  my ($class) = @_;
  
  # -- registration table of artifact constructors
  my $constructor = SMake::ToolChain::Constructor::Table->new();
  
  # -- initial name mangler
  my $mangler = SMake::ToolChain::Mangler::Mangler->new();
  
  # -- command builders with generic internal records
  my $builder = SMake::Executor::Builder::Group->new(
    [$SMake::Model::Const::SOURCE_TASK, SMake::Executor::Builder::Empty->new()],
    [$SMake::Model::Const::PUBLISH_TASK, SMake::Executor::Builder::Empty->new()],
    [$SMake::Model::Const::EXTERNAL_TASK, SMake::Executor::Builder::Compile->new(
        "addTargetResources")],
    [$SMake::Model::Const::CLEAN_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::SERVICE_DEP_TASK, SMake::Executor::Builder::Empty->new()],
    [$SMake::Model::Const::SERVICE_TASK, SMake::Executor::Builder::Compile->new()],
  );
  
  # -- command translators
  my $translator = SMake::Executor::Translator::Table->new(
      [$SMake::Model::Const::EXTERNAL_TASK,
       SMake::Executor::Translator::Instruction->new(
           SMake::Executor::Instruction::Install),
      ],
      [$SMake::Model::Const::CLEAN_TASK,
       SMake::Executor::Translator::Instruction->new(
           SMake::Executor::Instruction::Clean),
      ],
      [$SMake::Model::Const::SERVICE_TASK,
       SMake::Executor::Translator::Instruction->new(
           SMake::Executor::Instruction::CleanInstallArea),
    ]);
  
  # -- source scanners
  my $scanner = SMake::ToolChain::Scanner::Chain->new();
  
  # -- filters of external resources
  my $resfilter = SMake::ToolChain::ResourceFilter::Chain->new();
    
  # -- create the tool chain
  my $this = bless(
      SMake::ToolChain::ToolChain->new(
          $constructor,
          $mangler,
          $builder,
          $translator,
          $scanner,
          $resfilter
      ),
      $class);
      
  # -- helper table of named objects
  $this->{objects} = {};
  $this->{features} = {};
  
  return $this;
}

# Create or get a named object
#
# Usage: createObject($name, $module, @args)
#    name ...... name of the object
#    module .... module of the object
#    newfce .... a function which is run for new object
#    @args ..... additional arguments
# Returns: the object
sub createObject {
  my ($this, $name, $module, $newfce, @args) = @_;
  
  my $object = $this->{objects}->{$name};
  if(!defined($object)) {
    $object = $module->new(@args);
    $this->{objects}->{$name} = $object;
    &{$newfce}($object);
  }
  return $object;
}

# Begin specification of an artifact constructor
#
# Usage: registerConstructor($type)
#    type ........ type of the artifact
sub registerConstructor {
  my ($this, $type) = @_;

  my $resolver = SMake::ToolChain::Resolver::Chain->new();
  my $constructor = SMake::ToolChain::Constructor::Generic->new($resolver, []);
  $this->getConstructor()->appendConstructors([$type, $constructor]);
  $this->{curr_constructor} = $constructor;
  $this->{objects} = {};
}

sub computeKey {
  my $key = "";
  foreach my $arg (@_) {
    $key .= "::$arg";
  }
  return $key;
}

# Register a feature into the current constructor
#
# Usage: registerFeature($module, @args)
#    module ........ feature's module or a reference to an array [$module, $keys]
#    args .......... aditional arguments
sub registerFeature {
  my ($this, $module, @args) = @_;
  
  # -- get feature key
  my $key;
  my $modulename;
  my @static_args;
  if(ref($module) eq "ARRAY") {
  	$key = computeKey(@$module);
    $modulename = shift @$module;
    @static_args = @$module;
  }
  else {
    $key = $module;
    $modulename = $module;
    @static_args = ();
  }

  # -- static initialization  
  if(!$this->{features}->{$key}) {
    $modulename->staticRegister(
        $this, $this->{curr_constructor}, @static_args);
    $this->{features}->{$key} = 1;
  }
  
  # -- instance initialization
  $modulename->register(
      $this, $this->{curr_constructor}, @static_args, @args);
}

return 1;
