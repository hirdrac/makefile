#include "shared_lib.hh"
#include <cassert>

int main(int argc, char** argv)
{
  assert(sharedLibFn() == 42);
  return 0;
}
