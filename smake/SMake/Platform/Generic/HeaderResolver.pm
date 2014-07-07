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

# Generic header resolver
package SMake::Platform::Generic::HeaderResolver;

use SMake::ToolChain::Resolver::Publish;

@ISA = qw(SMake::ToolChain::Resolver::Publish);

use SMake::Data::Path;
use SMake::Model::Const;

# Create new header resolver
#
# Usage: new()
sub new {
  my ($class) = @_;
  my $this = bless(
      SMake::ToolChain::Resolver::Publish->new(
          '.*',
          '[.]h$',
          $SMake::Model::Const::PUBLISH_RESOURCE,
          $SMake::Model::Const::HEADER_MODULE,
          SMake::Data::Path->new($SMake::Model::Const::HEADER_MODULE)),
      $class);
  return $this;
}

return 1;
