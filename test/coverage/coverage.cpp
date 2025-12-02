#include "coverage.h"
#include "greeting/greeting.h"

namespace coverage {

// Extracted main logic for testing
void runMain(int argc, char* argv[]) noexcept {
    if (argc > 1) {
        greeting::printGreeting(argv[1]);
    } else {
        greeting::printGreeting("World");
    }
}

}  // namespace coverage