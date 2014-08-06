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

# Some constants
package SMake::Platform::Generic::Const;

# -- C compiling
$C_TASK = "c";
$C_RESOURCE = "c";

# -- C++ compiling
$CXX_TASK = "cxx";
$CXX_RESOURCE = "cxx";

# -- object files
$OBJ_RESOURCE = "obj";

# -- artifacts
$LIB_ARTIFACT = "lib";
$BIN_ARTIFACT = "bin";

# -- static libraries
$LIB_MAIN_TYPE = "staticlib";
$LIB_COMPILE_STAGE = "libcompile";
$LIB_STAGE = "liblink";
$LIB_TASK = "lib";
$LIB_RESOURCE = "lib";

# -- dynamic libraries
$DLL_MAIN_TYPE = "dynamiclib";
$DLL_COMPILE_STAGE = "dllcompile";
$DLL_STAGE = "dlllink";
$DLL_TASK = "dll";
$DLL_RESOURCE = "dll";

# -- executable binaries
$BIN_MAIN_TYPE = "binary";
$BIN_MAIN_TYPE_LINKER = "binary_linker";
$BIN_COMPILE_STAGE = "bincompile";
$BIN_STAGE = "binlink";
$BIN_TASK = "bin";
$BIN_RESOURCE = "bin";

# -- dependency types
$LINK_DEPENDENCY = "link";

# -- installation
$INSTALL_DEPENDENCY = "install";
$LIB_INSTALL_STAGE = "libinstall";
$HEADER_MODULE = "include";
$LIB_MODULE = "lib";

# -- profile variables
$VAR_HEADER_DIRECTORY = "HEADER_DIR";

# -- cleaning task
$CLEAN_STAGE = "clean";
$CLEAN_TASK = "clean";

# -- service stage and task
$SERVICE_ARTIFACT = "smake_service";
$SERVICE_DEPENDENCY = "smake_service";
$SERVICE_STAGE = "smake_service";
$SERVICE_TASK = "smake_service";
$SERVICE_DEP_TASK = "smake_dep_service";

# -- logical command groups
$PRODUCT_GROUP = "product";         # -- product files
$SOURCE_GROUP = "src";              # -- source files
$LIB_GROUP = "lib";                 # -- linked libraries
$HEADERDIR_GROUP = "header_dirs";   # -- searching paths of headers
$LIBDIR_GROUP = "lib_dirs";         # -- searching paths of libraries
$DEBUG_GROUP = "debug";             # -- debugging options
$PREPROC_GROUP = "preproc";         # -- C/C++ preprocessor options
$DLL_GROUP = "dll_opts";            # -- compilation options dependent on type of library
$LIB_TYPE_OPTION = "libtype";       # -- type of library (for compilation)
$RPATH_GROUP = "rpaths";            # -- rpath argument of an executable (searching of dynamic libraries)

return 1;
