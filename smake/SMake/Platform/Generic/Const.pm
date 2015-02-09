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

# -- extra files
$EXTRA_RESOURCE = "extra";

# -- headers
$H_RESOURCE = "h";

# -- C compiling
$C_TASK = "c";
$C_RESOURCE = "c";

# -- C++ compiling
$CXX_TASK = "cxx";
$CXX_RESOURCE = "cxx";

# -- GNU Flex generator
$FLEX_TASK = "flex";
$FLEX_RESOURCE = "flex";
$FLEX_STAGE = "flex";

# -- GNU Bison generator
$BISON_TASK = "bison";
$BISON_RESOURCE = "bison";
$BISON_STAGE = "bison";

# -- object files
$OBJ_RESOURCE = "obj";

# -- artifacts
$EMPTY_ARTIFACT = "empty";
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

# -- direct commands
$DIRECT_TASK = "direct";

# -- ant task
$ANT_TASK = "ant";
$ANT_GOALS = "goals";    # -- name of the goal argument of the ant task
$ANT_RESOURCE = "ant";   # -- ant build specification

# -- dependency types
$LINK_DEPENDENCY = "link";     # -- library linking

# -- library installation
$LIB_INSTALL_DEPENDENCY = "install";  # -- dependency of a task on the install stage
$LIB_INSTALL_STAGE = "libinstall";
$LIB_MODULE = "lib";

# -- header installation
$HEADER_MODULE = "include";

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
  $DEBUG_TYPE = "type";             # -- debugging type (full, profile, no)
$PREPROC_GROUP = "preproc";         # -- C/C++ preprocessor options
$DLL_GROUP = "dll_opts";            # -- compilation options dependent on type of library
  $LIB_TYPE_OPTION = "libtype";     # -- type of library (for compilation)
$RPATH_GROUP = "rpaths";            # -- rpath argument of an executable (searching of dynamic libraries)
$CFG_HEADER = "cfgheader";          # -- compiler configuration headers
$CFLAGS_GROUP = "cflags";           # -- generic C flags
$CXXFLAGS_GROUP = "cxxflags";       # -- generic C++ flags
$LDFLAGS_GROUP = "ldflags";         # -- generic linker flags
$BISON_GROUP = "bison";             # -- flex/bison options
  $BISON_PREFIX = "prefix";         # -- flex/bison class prefix
$ANT_VAR_GROUP = "antvars";         # -- group of ant variable options
$ANT_CMD_GROUP = "antcmds";         # -- group of ant commands (compilation targets)

return 1;
