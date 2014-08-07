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

# Some constants related to the model
package SMake::Model::Const;

# -- resource location types
$SOURCE_LOCATION = "source";
$PRODUCT_LOCATION = "product";
$EXTERNAL_LOCATION = "external";
$PUBLIC_LOCATION = "public";

# -- source files
$SOURCE_STAGE = "src";
$SOURCE_RESOURCE = "src";
$SOURCE_TASK = "src";

# -- external resources
$EXTERNAL_TASK = "install";

# -- public resources
$PUBLISH_TASK = "publish";

# -- resource translation
$RES_TRANSLATION_TASK = "resource_trans";

# -- construction of the build tree
$BUILD_TREE_STAGE = "smake_build_tree";
$BUILD_TREE_TASK = "smake_build_tree";
$BUILD_TREE_RESOURCE = "smake_build_tree";

return 1;
