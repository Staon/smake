#include "hello.h"

#include <iostream>

Hello::Hello() {

}

Hello::~Hello() {

}

void Hello::sayHello(
    std::ostream& os_) {
  os_ << "Hello world" << std::endl;
}
