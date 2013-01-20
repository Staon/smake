/*
 Copyright (C) 2013 Ondrej Starek - stareko@email.cz

 This file is part of SMake.

 SMake is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 SMake is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with SMake.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "hello.h"

#include <calc/calc.h>
#include <iostream>

namespace Examples {

namespace Hello {

Hello::Hello() {

}

Hello::~Hello() {

}

void Hello::sayHello(
    std::ostream& os_) {
  os_ << "Hello. Write an expression and press CTRL-D" << std::endl;
  Examples::Calculator::parse();
}

} /* -- namespace Hello */

} /* -- namespace Examples */
