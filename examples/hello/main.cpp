#include <iostream>
#include "hello.h"

int main(int argc_, char*argv_[]) {
  Hello hello_;
  hello_.sayHello(std::cout);
  return 0;
}
