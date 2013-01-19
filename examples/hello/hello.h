#ifndef HELLO__H
#define HELLO__H

#include <iosfwd>

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

#endif /* HELLO__H */
