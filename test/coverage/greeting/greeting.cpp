#include "greeting.h"
#include <iostream>

namespace greeting {

void printGreeting(const std::string& name) noexcept {
    if (name == "Uwe") {
        std::cout << "Hello there, Uwe! Great to see you!" << std::endl;
    } else {
        std::cout << "Hello, " << name << "!" << std::endl;
    }
}

}  // namespace greeting
