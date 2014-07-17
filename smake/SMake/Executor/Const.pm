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

# Constants for the execution model
package SMake::Executor::Const;

# -- group of product resources
$PRODUCT_GROUP = "product";

# -- group of source resources
$SOURCE_GROUP = "src";

# -- group of libraries
$LIB_GROUP = "lib";

# -- group of paths of headers
$HEADERDIR_GROUP = "header_dirs";

# -- group of paths of libraries
$LIBDIR_GROUP = "lib_dirs";

# -- group of debug options
$DEBUG_GROUP = "debug";

# -- group of preprocessor options
$PREPROC_GROUP = "preproc";

# -- group of DLL options
$DLL_GROUP = "dll_opts";
$LIB_TYPE_OPTION = "libtype";
$RPATH_GROUP = "rpaths";

return 1;
