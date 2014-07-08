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

# -- artifacts
$LIB_ARTIFACT = "lib";
$BIN_ARTIFACT = "bin";

# -- source files
$SOURCE_STAGE = "src";
$SOURCE_RESOURCE = "src";
$SOURCE_TASK = "src";

# -- created files
$PRODUCT_RESOURCE = "product";

# -- compiling
$COMPILE_STAGE = "compile";
$C_TASK = "c";
$CXX_TASK = "cxx";

# -- static libraries
$LIB_MAIN_TYPE = "static_lib";
$LIB_STAGE = "liblink";
$LIB_TASK = "lib";

# -- dynamic libraries
$DLL_MAIN_TYPE = "dynamic_lib";
$DLL_STAGE = "dlllink";
$DLL_TASK = "dll";

# -- executable binaries
$BIN_MAIN_TYPE = "binary";
$BIN_STAGE = "binlink";
$BIN_TASK = "bin";

# -- dependency types
$LINK_DEPENDENCY = "link";

# -- external resources
$EXTERNAL_TASK = "install";
$EXTERNAL_RESOURCE = "external";

# -- public resources
$PUBLISH_STAGE = "publish";
$PUBLISH_RESOURCE = "public";
$PUBLISH_TASK = "publish";

# -- installation
$INSTALL_DEPENDENCY = "install";
$LIB_INSTALL_STAGE = "libinstall";
$HEADER_MODULE = "include";
$LIB_MODULE = "lib";

# -- profile variables
$VAR_HEADER_DIRECTORY = "HEADER_DIR";

return 1;
