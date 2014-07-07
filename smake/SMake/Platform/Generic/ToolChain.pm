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
use SMake::Executor::Translator::Table;
use SMake::Model::Const;
use SMake::ToolChain::Constructor::Table;
use SMake::ToolChain::Mangler::Mangler;
use SMake::ToolChain::ResourceFilter::Chain;
use SMake::ToolChain::Scanner::Chain;

# Create new tool chain object
#
# Usage: new($runner)
#    runner ..... shell runner
sub new {
  my ($class, $runner) = @_;
  
  # -- construct objects
  my $constructor = SMake::ToolChain::Constructor::Table->new();
  my $mangler = SMake::ToolChain::Mangler::Mangler->new();
  my $builder = SMake::Executor::Builder::Group->new(
    [$SMake::Model::Const::SOURCE_TASK, SMake::Executor::Builder::Empty->new()],
    [$SMake::Model::Const::C_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::CXX_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::LIB_TASK, SMake::Executor::Builder::Compile->new()],
    [$SMake::Model::Const::BIN_TASK, SMake::Executor::Builder::Compile->new(
        "addResources", "addLibraries")],
    [$SMake::Model::Const::PUBLISH_TASK, SMake::Executor::Builder::Empty->new()],
    [$SMake::Model::Const::EXTERNAL_TASK, SMake::Executor::Builder::Compile->new(
        "addTargetResources")],
  );
  my $translator = SMake::Executor::Translator::Table->new();
  my $scanner = SMake::ToolChain::Scanner::Chain->new();
  my $resfilter = SMake::ToolChain::ResourceFilter::Chain->new();
    
  # -- create the tool chain
  my $this = bless(
      SMake::ToolChain::ToolChain->new(
          $constructor,
          $mangler,
          $builder,
          $translator,
          $runner,
          $scanner,
          $resfilter
      ),
      $class);
  
  $this->registerExternal($SMake::Model::Const::HEADER_RESOURCE);
  $this->registerExternal($SMake::Model::Const::LIB_RESOURCE);
  
  return $this;
}

return 1;
