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

# Toolchain for Aveco building environment (QNX4, OpenWatcom)
package SMake::Platform::Aveco::ToolChain;

use SMake::Platform::Generic::ToolChain;

@ISA = qw(SMake::Platform::Generic::ToolChain);

use SMake::Executor::Const;
use SMake::Model::Const;
use SMake::Platform::Aveco::Bin;
use SMake::Platform::Aveco::Lib;
use SMake::Platform::Generic::ToolChain;
use SMake::Profile::ValueProfile;
use SMake::ToolChain::ResourceFilter::SysLocation;

# Create the toolchain
#
# Usage: new()
#    repository ...... the most significant repository
#    profiles ........ profile stack
sub new {
  my ($class) = @_;
  my $this = bless(SMake::Platform::Generic::ToolChain->new());

  # -- library artifact
  $this->registerConstructor($SMake::Model::Const::LIB_ARTIFACT);
  $this->registerFeature(SMake::Platform::Aveco::Lib);

  # -- binary artifact
  $this->registerConstructor($SMake::Model::Const::BIN_ARTIFACT);
  $this->registerFeature(SMake::Platform::Aveco::Bin);

  # -- generic preprocessor profile
  $this->registerProfile(
      "preproc",
      SMake::Profile::ValueProfile,
      $SMake::Model::Const::C_TASK . "|" . $SMake::Model::Const::CXX_TASK,
      $SMake::Executor::Const::PREPROC_GROUP,
      0);

  # -- resource filters
  $this->getResourceFilter()->appendFilters(
      SMake::ToolChain::ResourceFilter::SysLocation->new("/usr/include"),
  );
  
  return $this;
}

return 1;
