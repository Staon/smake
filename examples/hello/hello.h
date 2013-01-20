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

#ifndef HELLO__H
#define HELLO__H

#include <iosfwd>

namespace Examples {

namespace Hello {

class Hello {
  private:
    /* -- avoid copying */
    Hello(const Hello &);
    Hello & operator = (const Hello &);

  public:
    Hello();
    ~Hello();

    void sayHello(
        std::ostream& os_);
};

} /* -- namespace Hello */

} /* -- namespace Examples */

#endif /* HELLO__H */
